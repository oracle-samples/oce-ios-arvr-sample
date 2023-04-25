// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI
import SceneKit
import OracleContentCore

/**
 SwiftUI wrapper of an SCNView
 */
struct SphericalViewContainer: UIViewRepresentable {

    var currentItem: PanoramaExperienceItem
    var currentImage: URL?

    init(currentItem: PanoramaExperienceItem, currentImage: URL?) {
        self.currentItem = currentItem
        self.currentImage = currentImage
    }

    func makeUIView(context: Context) -> PanoramaSCNView {
        return PanoramaSCNView(horizontalAngle: self.currentItem.horizontalAngle, fieldOfView: self.currentItem.fieldOfView, currentImage: self.currentImage)
    }
    
    func updateUIView(_ uiView: PanoramaSCNView, context: Context) {

        let sphere = uiView.scene?.rootNode.childNodes.first { $0.name == "SPHERENODE"}
        if let firstMaterial = sphere?.geometry?.firstMaterial {

            if let foundURL = self.currentItem.url,
               let baseImage = UIImage(contentsOfFile: foundURL.path) {
                
                firstMaterial.diffuse.contents = baseImage.withHorizontallyFlippedOrientation()
                uiView.updateCamera(newY: self.currentItem.horizontalAngle, fieldOfView: self.currentItem.fieldOfView)

            }
        }
    }
}

/**
 The PanoramaSCNView creates a large sphere with a 360 degree image as its material. The camera is positioned inside the sphere such that rotating the camera simulates looking left, right, up and/or down "inside" the image
 */
class PanoramaSCNView: SCNView {
    let cameraNode = SCNNode()
    
    // determines how wide the initial view is
    var defaultFOV: Double = 60.0
    var currentFieldOfView: Double = 60.0
    
    // all angles are specified in radians
    // used to determine which part of image the camera is pointing at
    // specified as part of the content item
    var defaultX: Double = 0.0
    var defaultY: Double = 0.0
    var currentAngleX: Double = 0.0
    var currentAngleY: Double = 0.0
    var currentAngleZ: Double = 0.0
    
    init(horizontalAngle: Double, fieldOfView: Int, currentImage: URL?) {
        
        super.init(frame: .zero, options: nil)

        self.backgroundColor = .clear
        self.scene = SCNScene()
       
        self.autoenablesDefaultLighting = true
        
        //Create a camera node which will be the view of the user
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0,0,0)
        self.updateCamera(newY: horizontalAngle, fieldOfView: fieldOfView)
        self.scene?.rootNode.addChildNode(cameraNode)
        
        //Create the sphere geometry using the panoramic image as a texture
        let sphere = SCNSphere(radius: 30)
        sphere.name = "SPHERE"
        
        sphere.firstMaterial!.isDoubleSided = true
       
        // With the geometry now available, create the SCNNode and add it to the scene
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.rotation = SCNQuaternion(0, 1, 0, 0)
        sphereNode.position = SCNVector3Make(0,0,0)
        sphereNode.name = "SPHERENODE"
        self.scene?.rootNode.addChildNode(sphereNode)

        // add gestures
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        self.addGestureRecognizer(pinchGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Reposition the camera's horizontal positioning.
     - parameter newY: The new angle (in radians) to point to horizontally
     - parameter fieldOfView: The new field of view
     */
    func updateCamera(newY: Double, fieldOfView: Int) {
        self.defaultY = newY
        currentAngleX = defaultX
        currentAngleY = defaultY
        
        cameraNode.eulerAngles.x = Float(currentAngleX)
        cameraNode.eulerAngles.y = Float(currentAngleY)
        
        self.defaultFOV = Double(fieldOfView)
        self.cameraNode.camera?.fieldOfView = self.defaultFOV
    }
    
    deinit {
        self.gestureRecognizers?.removeAll()
    }
    
    /**
     Gesture recognizer code that allow for looking left, right, up and down
     */
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
      
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!)
        
        var newAngleX = (translation.y)*(Double.pi)/180.0
        newAngleX += currentAngleX
        
        var newAngleY = (translation.x)*(Double.pi)/180.0
        newAngleY += currentAngleY
        
        cameraNode.eulerAngles.x = Float(newAngleX)
        cameraNode.eulerAngles.y = Float(newAngleY)
     
        if(gestureRecognizer.state == .ended) {
            currentAngleX = newAngleX
            currentAngleY = newAngleY
        }
    }
    
    /**
     Method to handle tapping on an area of the image.
     
     Currently, this method does nothing but briefly flash the color red to indicate that the tap was processed.
     You could, however, do other things like perform calculations to determine if a specific area of the 360 degree image was tapped.
     */
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: self)
        let hitResults = self.hitTest(p, options: [:])
        
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get material for selected geometry element
            let material = result.node.geometry!.firstMaterial
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material?.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material?.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    /**
     Gesture recognizer code that allows for altering the field of view
     */
    @objc func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
        
        // Set zoom properties
        let minVelocity = CGFloat(0.10)
        let zoomDelta = 0.5
        
        // Only zoom when gesture changing and when velocity exceeds <minVelocity>
        if gestureRecognizer.state == .changed {
            // Ignore gesture on tiny movements
            if abs(gestureRecognizer.velocity) <= minVelocity {
                return
            }
            
            // If here, zoom in or out based on velocity
            let deltaFov = gestureRecognizer.velocity > 0 ? -zoomDelta : zoomDelta
            cameraNode.camera?.fieldOfView += deltaFov
        }
    }
    
    /**
     Reset the view to the default values
     */
    func reset() {
        self.cameraNode.eulerAngles.x = Float(defaultX)
        self.cameraNode.eulerAngles.y = Float(defaultY)
        self.currentAngleX = defaultX
        self.currentAngleY = defaultY
        self.cameraNode.camera?.fieldOfView = defaultFOV
        
    }
}

