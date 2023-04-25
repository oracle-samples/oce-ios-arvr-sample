// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine
import OracleContentCore
import OracleContentDelivery
import ARDemoCommon

/**
 Supported actions of the panorama model
 */
enum PanoramaModelAction {
    case download
    case reset
    case failure(Error)
    case showNext
    case showPrevious
    case displayCurrent
    case close
    case displayFetchingNextSpinner
    case newLocation(Asset)
    case buildExperienceItems(Asset)
    case updateData(String, [PanoramaExperienceItem])
}

/**
 Possible UI states of panorama demo
 */
enum PanoramaState {
    case none
    case downloading
    case building
    case creatingExperienceItem
    case error(Error)
    case done
    case close
}

class PanoramaModel: ObservableObject {
    
    @Published var state: PanoramaState = .none
    @Published var fetchingNext = false
    @Published var locations = [Asset]()
    @Published var currentLocationName: String = ""
    
    var panoramaParameters: PanoramaURLParameters!
    
    var currentIndex = -1
    @Published var currentPanoramaImage: URL?
    
    var currentItem: PanoramaExperienceItem {
        self.data.items[currentIndex]
    }
    
    /// Action to be called when the view closes
    private var onCloseAction: (() -> Void)?
    
    /// The collection of 360 degree images associated with a particular location
    private var data: PanoramaExperience!
    
    /// Cancellables to used for publisher retention
    private var cancellables = [AnyCancellable]()
    
    /// injectable networking code - defaults to PanoamaNetworking.self
    private var networking: PanoramaNetworkingProtocol.Type
    
    /// injectable cache provider - defaults to ARDemoCacheProvider()
    private var cacheProvider: CacheProvider
    
    /**
     PanoramaModel initializer
     
     - parameter queryItems: The query items extracted from the URL received by the application
     - parameter networking: Optional (injectable) networking code. Defaults to PanoramaNetworking.self
     - parameter cacheProvider: Optional (injectable) cache provider. Defaults to ARDemoCacheProvider()
     - parameter onClose: Function to call when closing the demo view
     */
    public init(queryItems: [URLQueryItem]?,
                networking: PanoramaNetworkingProtocol.Type? = nil,
                cacheProvider: CacheProvider? = nil,
                onClose: (() -> Void)? = nil) {
       
        self.networking = networking ?? PanoramaNetworking.self
        self.cacheProvider = cacheProvider ?? ARDemoFileCache.instance
        self.onCloseAction = onClose
        
        do {
            self.panoramaParameters = try PanoramaURLParameters(queryItems: queryItems)
        } catch {
            self.send(.failure(error))
        }
    }
    
    // Handle model actions
    // All state changes occur here
    func send(_ action: PanoramaModelAction) {
        switch action {
        case .download:
            self.state = .downloading
            self.fetchingNext = false
            self.fetch()
            
            if self.locations.isEmpty {
                self.fetchListing()
            }
           
        case .failure(let error):
            self.fetchingNext = false
            self.state = .error(error)
            
        case .displayCurrent:
            self.fetchingNext = false
            guard let url = self.data.items[self.currentIndex].url else {
                self.state = .error(PanoramaError.invalidCacheURL)
                return
            }
            
            DispatchQueue.main.async {
                self.currentPanoramaImage = url
                self.state = .done
            }
           
        case .showNext:
            self.fetchNext()
            
        case .showPrevious:
            self.fetchPrevious()
            
        case .close:
            self.fetchingNext = false
            self.panoramaParameters = nil
            self.currentPanoramaImage = nil
            self.data?.items.removeAll()
            self.data = nil
            self.state = .close
            self.onCloseAction?()
            
        case .displayFetchingNextSpinner:
            self.fetchingNext = true
            
        case .newLocation(let asset):
            self.state = .downloading
            self.fetchingNext = false
            self.panoramaParameters = self.create(parameters: panoramaParameters, assetId: asset.identifier)
            self.data.items.removeAll()
            self.currentIndex = -1
            self.fetch()
            
        case let .updateData(name, experienceItems):
            self.data = PanoramaExperience(location: name, items: experienceItems)
            self.currentLocationName = name
            
        case .buildExperienceItems(let asset):
            self.buildExperienceItems(from: asset)
            
        default:
            break
        }
    }
    
    private func create(parameters: PanoramaURLParameters, assetId: String) -> PanoramaURLParameters {
        var newParameters = parameters
        newParameters.assetId = assetId
        return newParameters
    }
    
    private func buildExperienceItems(from asset: Asset) {
 
       let location = asset.name
        
        guard let panoramaImages = try? asset.customField("360Scenes") as [Asset] else {
            self.send(.failure(PanoramaError.noImagesAvailable))
            return
        }
        
        guard !panoramaImages.isEmpty else {
            self.send(.failure(PanoramaError.noImagesAvailable))
            return
        }
        
        let experienceItems = panoramaImages.map { asset -> PanoramaExperienceItem in
            
            let assetTitle = try? asset.customField("title") as String
    
            let horizontalAngle = (try? asset.customField("horizontalAngle") as Double) ?? 0.0
            let fieldOfView = (try? asset.customField("fieldOfView") as Int) ?? 0   
            
            return PanoramaExperienceItem(
                identifier: asset.identifier,
                title: assetTitle,
                horizontalAngle: horizontalAngle,
                fieldOfView: fieldOfView,
                url: nil)
        }
        
        self.send(.updateData(location, experienceItems))
        
        self.send(.showNext)
    }

}

// MARK: Network Behaviors
extension PanoramaModel {
    
    func fetch()  {
        
        var c: AnyCancellable?
        c = self.networking
            .readAsset(basedOn: self.panoramaParameters)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.send(.failure(error))
                    
                default:
                    break
                }
                
                self.cancellables.removeAll { $0 === c }
            } receiveValue: { asset in
                self.send(.buildExperienceItems(asset))
            }
        
        c?.store(in: &self.cancellables)

    }
    
    func fetchListing() {
        var c: AnyCancellable?
        c = self.networking
            .listAssets(basedOn: self.panoramaParameters)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.send(.failure(error))
                    
                default:
                    break
                }
                
                self.cancellables.removeAll { $0 === c }
            }, receiveValue: { assets in
                self.locations = assets.items
            })
    }
    
    
    func fetchNext() {
        self.currentIndex = abs((self.currentIndex + 1) % self.data.items.count)
        self.fetchCurrent()
        
    }
    
    func fetchPrevious() {
        self.currentIndex = abs((self.currentIndex + self.data.items.count - 1) % self.data.items.count)
        self.fetchCurrent()
    }
    
    func fetchCurrent() {
        
        if self.currentIndex < 0 || self.currentIndex > (self.data.items.count - 1) {
            self.send(.failure(PanoramaError.invalidIndex))
            return
        }
        
        guard currentItem.url == nil else {
            self.send(.displayCurrent)
            return
        }
        
        self.send(.displayFetchingNextSpinner)
        
        let identifier = self.data.items[self.currentIndex].identifier
        
        var c: AnyCancellable?
        c = self.networking
            .downloadNative(basedOn: panoramaParameters,
                                              identifier: identifier,
                                              cacheProvider: cacheProvider,
                                              cacheKey: identifier)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.send(.failure(error))
                    
                default:
                    break
                }
                
                self.cancellables.removeAll { $0 === c }
            }, receiveValue: { downloadResult in
                self.data.items[self.currentIndex].url = downloadResult.result
                
                self.send(.displayCurrent)
            })
        
        c?.store(in: &self.cancellables)
        
        
    }
}
