// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine
import OracleContentCore
import OracleContentDelivery
import RealityKit
import ARKit
import ARDemoCommon

/**
 Possible UI states for the Mug Demo
 */
internal enum MugState {
    case waitingToStart
    case downloading
    case loading
    case customizing
    case error(Error)
    case done
}

/**
 Supported actions of the Mug model
 */
internal enum MugAction {
    case close
    case download
    case build
    case display
    case performCustomization(Entity)
    case fail(Error)
}

/**
 Defines the data necesary to customize a mug model
 */
public struct MugMaterials {
    
    /// The location of the downloaded USDZ file
    let renditionURL: URL
    
    /// The location of the image to be used as the mug decal
    let decalURL: URL
    
    /// The name of the main mesh in the model USDZ file
    let mainMesh: String
    
    /// The names of the text meshes in the model USDZ file
    let textMeshes: [String]
    
    /// The names of the image meshes in the model USDZ file
    let imageMeshes: [String]
    
    /// The name of the product
    let productName: String?
    
    /// The price of the product
    let price: String?
}

internal class MugModel: ObservableObject {
    
    @Published var state: MugState = .waitingToStart
    @Published var awaitingModel = true
    
    ///  Defines the data necesary to customize a mug model
    internal var customizableMaterials: MugMaterials!
    internal var usdz: Entity!
    
    private var onCloseAction: (() -> Void)?
    private var customizableParameters: MugURLParameters!
    private var cancellables = [AnyCancellable]()
    private var shader: CustomMaterial.SurfaceShader! = MugModel.createSurfaceShader()
    
    /// Injectable cache provider to use - will default to ARDemoCacheProvider()
    private var cacheProvider: CacheProvider
    
    /// Injectable networking code - will default to MugNeworking.self
    private var networking: MugNetworkingProtocol.Type
    
    /**
     MugModel initializer
     
     - parameter queryItems: The query items extracted from the URL received by the application
     - parameter networking: Optional (injectable) networking code. Defaults to MugNetworking.self
     - parameter cacheProvider: Optional (injectable) cache provider. Defaults to ARDemoCacheProvider()
     - parameter onClose: Function to call when closing the demo view
     */
    internal init(queryItems: [URLQueryItem]?,
                  networking: MugNetworkingProtocol.Type? = nil,
                  cacheProvider: CacheProvider? = nil,
                  onClose: (() -> Void)? = nil) {
        
        self.onCloseAction = onClose
        self.networking = networking ?? MugNetworking.self
        self.cacheProvider = cacheProvider ?? ARDemoFileCache.instance
       
        do {
            self.customizableParameters = try  MugURLParameters.init(queryItems: queryItems)
            
        } catch {
            self.send(.fail(error))
        }
    }
    
    /// Handle model actions
    /// All state changes occur here
    internal func send(_ action: MugAction) {
        switch action {
        case .download:
            self.state = .downloading
            self.fetch(using: self.customizableParameters, cacheProvider: self.cacheProvider)
            
        case .build:
            self.state = .loading
            self.loadModel()
            
        case .display:
            self.state = .done
            
        case .fail(let error):
            Onboarding.logError(error.localizedDescription)
            self.state = .error(error)
            
        case .close:
            self.usdz = nil
            self.shader = nil
            self.customizableMaterials = nil
            self.state = .waitingToStart
            self.onCloseAction?()
            
        case .performCustomization(let entity):
            self.state = .customizing
            self.usdz = entity
            self.performCustomization()
        }
    }
}

// MARK: Shader code
extension MugModel {
    
    /// Create the metal shader used to handle "transparent" pixels
    /// Absent this shader, the demo models displaying a logos and text with a visible "filming" background where the pixels shouljd be transparent
    private static func createSurfaceShader() -> CustomMaterial.SurfaceShader {
        guard let device = MTLCreateSystemDefaultDevice(),
              let library = try? device.makeDefaultLibrary(bundle: Bundle.module) else {
            fatalError("Error creating default metal device.")
        }
        
        // Load a surface shader function to handle transparent pixels and eliminate "filming" issues
        return CustomMaterial.SurfaceShader(named: "mySurfaceShader",
                                            in: library)
    }
}

// MARK: Materials Code
extension MugModel {
    
    /**
     Load the USDZ file and then apply customizations for coloring, decals and text
     */
    internal func loadModel() {
                
            var c: AnyCancellable?
            c = ModelEntity.loadAsync(contentsOf: self.customizableMaterials.renditionURL)
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        self.send(.fail(error))
                        
                    default:
                        break
                    }
                    
                    self.cancellables.removeAll { $0 === c }
                } receiveValue: { entity in
                    self.send(.performCustomization(entity))
                }
            
            c?.store(in: &self.cancellables)
    }
    
    /**
     Perform the customization of the USDZ file by applying coloring, decals and text
     */
    private func performCustomization() {
        do {
            // Colorize the main mesh
            try self.setMaterialColor(model: self.usdz,
                                      meshName: self.customizableMaterials.mainMesh,
                                      baseColor: ColorFunctions.hexColor(self.customizableParameters.mugColor),
                                      roughness: 0.0)

            // Set decals
            try self.setMaterialImage(model: self.usdz,
                                      meshName: self.customizableMaterials.imageMeshes[0],
                                      imageURL: self.customizableMaterials.decalURL,
                                      shader: self.shader)
            try self.setMaterialImage(model: self.usdz,
                                      meshName: self.customizableMaterials.imageMeshes[1],
                                      imageURL: self.customizableMaterials.decalURL,
                                      shader: self.shader)
            
            // Set custom text
            if let customText = self.customizableParameters.text {
                let textImageURL = try self.createTextImage(text: customText,
                                                            color: ColorFunctions.hexColor(self.customizableParameters.textColor ?? 0x000000))
                try self.setMaterialImage(model: self.usdz,
                                          meshName: self.customizableMaterials.textMeshes[0],
                                          imageURL: textImageURL,
                                          shader: self.shader)
                try self.setMaterialImage(model: self.usdz,
                                          meshName: self.customizableMaterials.textMeshes[1],
                                          imageURL: textImageURL,
                                          shader: self.shader)
                
            } else {
                // No text specified so set the material of the text meshes to the same as the mug
                try self.setMaterialColor(model: self.usdz,
                                          meshName: self.customizableMaterials.textMeshes[0],
                                          baseColor: ColorFunctions.hexColor(self.customizableParameters.mugColor),
                                          roughness: 0.0)
                try self.setMaterialColor(model: self.usdz,
                                          meshName: self.customizableMaterials.textMeshes[1],
                                          baseColor: ColorFunctions.hexColor(self.customizableParameters.mugColor),
                                          roughness: 0.0)
            }
            
            // Trigger the display of the new model
            self.send(.display)
        } catch {
            self.send(.fail(error))
        }
    }
    
    /// Update the specified mesh's material with the provided color and PBR values
    private func setMaterialColor(model: Entity,
                                  meshName: String,
                                  baseColor: UIColor,
                                  roughness: PhysicallyBasedMaterial.Roughness = 0.0,
                                  clearcoat: PhysicallyBasedMaterial.Clearcoat = 1.0,
                                  metallic: PhysicallyBasedMaterial.Metallic = 0.2) throws {
        
        if let object = model.findEntity(named: meshName) {
            var pbrMaterial = PhysicallyBasedMaterial()
            
            pbrMaterial.baseColor = PhysicallyBasedMaterial.BaseColor(tint: baseColor, texture: nil)
            pbrMaterial.roughness = roughness
            pbrMaterial.clearcoat = clearcoat
            pbrMaterial.metallic = metallic
            
            (object as? ModelEntity)?.model?.materials = [pbrMaterial]
        } else {
            let error = MugDemoError.noMeshWithName(meshName)
            Onboarding.logError(error.localizedDescription)
            throw error
        }
    }
    
    /// Update the specified mesh's material with the provided imageURL
    private func setMaterialImage(model: Entity,
                                  meshName: String,
                                  imageURL: URL,
                                  shader: CustomMaterial.SurfaceShader) throws {
        if let object = model.findEntity(named: meshName) {
            var pbrMaterial = PhysicallyBasedMaterial()

            do {
                let texture = try TextureResource.load(contentsOf: imageURL)
                let textureParam = MaterialParameters.Texture(texture)

                pbrMaterial.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .white, texture: textureParam)
                pbrMaterial.roughness = 0.0

                let c = try CustomMaterial(from: pbrMaterial, surfaceShader: shader)


                (object as? ModelEntity)?.model?.materials = [c]
            
            } catch {
                Onboarding.logError(error.localizedDescription)
                throw MugDemoError.couldNotLoadTextureFromURL
              
            }
        } else {
            let error = MugDemoError.noMeshWithName(meshName)
            Onboarding.logError(error.localizedDescription)
            throw error
        }
    }
    
    private func createTextImage(text: String, color: UIColor) throws -> URL {
        
        // Start with large attributed text
        let attributedText = NSAttributedString(
            string: text,
            attributes: [.font: UIFont.systemFont(ofSize: 150, weight: .medium),
                         .foregroundColor: color]
        )
        
        // Utilize UIKit to obtain an image of the text
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.attributedText = attributedText
        label.sizeToFit()
        let labelImage = UIImage.imageWithLabel(label)!
        
        // The labelImage could be big so resize it to the desired dimensions (matching the UV wrapping in the model)
        let intermediateImage = labelImage.resize(withSize: CGSize(width: 1200, height: 200), contentMode: .contentAspectFit)!
        
        // Merge the intermediate image with a transparent placeholder image as the final step to ensure the text displays appropropriately
        let finalImage = merge(textDecal: intermediateImage)
        
        // Write the image to the temp directory so that we have a URL to use when setting the material property
        let imageName = UUID().uuidString
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(imageName)
        
        do {
            try finalImage.pngData()?.write(to: tempURL)
        } catch {
            Onboarding.logError(error.localizedDescription)
            throw MugDemoError.failureWritingTextImageToDisk
        }
        
        return tempURL
    }
    
    private func merge(textDecal: UIImage) -> UIImage {
        var placeholderImage = UIImage(named: "TextPlaceholder_1200x200", in: .module, compatibleWith: nil)!
        let placeholderSize = placeholderImage.size
        let renderer = UIGraphicsImageRenderer(size: placeholderSize)
        let newX = (placeholderSize.width - textDecal.size.width) / 2
        let newY = (placeholderSize.height - textDecal.size.height) / 2
        
        placeholderImage = renderer.image {
            _ in
            placeholderImage.draw(at:.zero)
            textDecal.draw(at: CGPoint(x: newX, y: newY))
        }
        
        return placeholderImage
    }
}

extension MugModel {
    /**
     Call networking code to fetch the mug and the components from the Oracle Content server
     */
    private func fetch(using customizableParameters: MugURLParameters,
                        cacheProvider: CacheProvider) {
        
        var c: AnyCancellable?
        c = self.networking
            .obtainServerData(using: customizableParameters,
                                           cacheProvider: cacheProvider)
            .tryMap(self.createCustomizableMaterials)                              
            .eraseToAnyPublisher()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.send(.fail(error))
                    
                default:
                    break
                }
                
                self.cancellables.removeAll { $0 === c }
                
            }, receiveValue: { customizableMaterials in
                self.customizableMaterials = customizableMaterials
                self.send(.build)
                
            })
        
        c?.store(in: &self.cancellables)
    }
    
    private func createCustomizableMaterials(_ asset: Asset, _ renditionURL: DownloadResult<URL>, _ decalURL: DownloadResult<URL>) throws -> MugMaterials {
        
        guard let model = try? asset.customField("model") as Asset else {
            throw MugDemoError.modelMissing
        }
        
        guard let mainMesh = try? model.customField("primarymeshname") as String else {
            throw MugDemoError.primaryMeshMissing
        }
        
        guard let imageMeshes = try? model.customField("imagemeshnames") as [String] else {
            throw MugDemoError.imageMeshesMissing
        }

        guard !imageMeshes.isEmpty else {
            throw MugDemoError.imageMeshesMissing
        }
        
        let textMeshes = (try? model.customField("textmeshnames") as [String]) ?? []

        let priceDoubleValue = try? asset.customField("price") as Double
        let price = priceDoubleValue != nil ? String(priceDoubleValue!) : ""
        let name = asset.name
        
        let customizable = MugMaterials(
            renditionURL: renditionURL.result,
            decalURL: decalURL.result,
            mainMesh: mainMesh,
            textMeshes: textMeshes,
            imageMeshes: imageMeshes,
            productName: name,
            price: price
        )
        
        return customizable
    }
}
