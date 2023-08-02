// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// The collection of 360 degree images associated with a particular location
class PanoramaExperience {
    var location: String
    var item: PanoramaExperienceItem
    
    init(location: String, item: PanoramaExperienceItem) {
        self.location = location
        self.item = item
    }
}

/**
 Information about a specific 360 degree image
 */
class PanoramaExperienceItem {
    
    /// The identifier of the asset in Oracle Content Management
    let identifier: String
    
    /// The title to use for the image
    var title: String
    
    /// The direction (in Radians) that the camera should point
    var horizontalAngle: Double
    
    /// The depth of field to use for the camera
    var fieldOfView: Int
    
    /// The location of the downloaded image
    var url: URL?
    
    init(identifier: String, title: String?, horizontalAngle: Double?, fieldOfView: Int, url: URL? = nil) {
        self.identifier = identifier
        self.title = title ?? ""
        self.url = url
        self.fieldOfView = fieldOfView
        
        let radians = (horizontalAngle ?? 0.0) * Double.pi / 180
        self.horizontalAngle = radians 
    }
}
