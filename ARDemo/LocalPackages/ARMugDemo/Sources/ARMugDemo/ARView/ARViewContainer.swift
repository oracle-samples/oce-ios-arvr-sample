// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI
import RealityKit
import ARKit 

/// Swift UI container housing (ultimately) an ARView that is used to display the downloaded mug model with customizations
struct ARViewContainer: UIViewRepresentable {

    var arContainer: ARViewContainerClass!
   
    @EnvironmentObject var model: MugModel
    
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        var arViewContainerClass: ARViewContainerClass!
        var model: MugModel
        
        init(_ arViewContainer: ARViewContainer, model: MugModel) {
            self.parent = arViewContainer
            self.model = model
            super.init()
        }
        
        func createARView() {
            self.arViewContainerClass = ARViewContainerClass(model.usdz, mainMesh: model.customizableMaterials.mainMesh)
        }
        
    }
    
    init() { }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self, model: model)
    }
    
    func makeUIView(context: Context) -> ARView {
        context.coordinator.createARView()
        return context.coordinator.arViewContainerClass.arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}

// Underlying class object which contains the ARView and establishes configuration options
class ARViewContainerClass: NSObject {
    
    var arView: ARView = ARView(frame: .zero)
    var usdz: Entity!
    var mainMesh: String
    var anchor: AnchorEntity!
    
    deinit {
        arView.session.pause()
        arView.session.delegate = nil
        arView.scene.anchors.removeAll()
        arView.removeFromSuperview()
        arView.gestureRecognizers?.removeAll()
        anchor = nil
        arView.window?.resignKey()
        self.anchor = nil
        self.usdz = nil
    }

    init(_ usdz: Entity, mainMesh: String) {
        
        self.usdz = usdz
        self.mainMesh = mainMesh
        
#if targetEnvironment(simulator)
        
        anchor = AnchorEntity()
        arView.cameraMode = .nonAR
        arView.environment.background = .color(.gray)
        
        let cameraAnchor = AnchorEntity(world: [0, 0.02, 0.2])
        cameraAnchor.addChild(PerspectiveCamera())
        arView.scene.addAnchor(cameraAnchor)
#else
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            
            arView.environment.lighting.intensityExponent = 2
            
            arView.automaticallyConfigureSession = false
            let config = ARWorldTrackingConfiguration()
            config.sceneReconstruction = .mesh
            config.planeDetection = .horizontal
            config.isLightEstimationEnabled = true
            arView.session.run(config)
        }
        
        anchor = AnchorEntity(.plane([.horizontal],
                                     classification: [.table, .floor],
                                     minimumBounds: [0.375, 0.375]))
        
#endif
        super.init()
        
        if let mugMesh = self.usdz.findEntity(named: self.mainMesh) as? ModelEntity {
            mugMesh.generateCollisionShapes(recursive: true)
            self.arView.installGestures([.all], for: mugMesh)
        }
    
        // create an anchor for detected planes
        anchor.addChild(usdz)
        arView.session.configuration?.frameSemantics.insert(.personSegmentationWithDepth)
        arView.scene.anchors.append(anchor)
    }
}
