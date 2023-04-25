// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Defines the supported demos in this project
public enum SupportedDemos: String, Identifiable {
    case unknown
    case mug
    case panorama
    
    public var id: Self { self }
    
    public init(rawValue: String?) {
        
        guard let value = rawValue else {
            self = .unknown
            return
        }
        
        switch value.lowercased() {
        case "mug":
            self = .mug
            
        case "panorama":
            self = .panorama
            
        default:
            self = .unknown
        }
    }
}
