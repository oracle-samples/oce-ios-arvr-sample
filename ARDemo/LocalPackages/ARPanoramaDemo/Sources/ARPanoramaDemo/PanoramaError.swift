// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/**
 Errors that can be returned as part of the panorma viewing experience
 */
enum PanoramaError: Error {
    case queryItemsMissing
    case urlParameterMissing
    case couldNotCreateURLFromParameter
    case tokenParameterMissing
    case assetIdParameterMissing
    case noImagesAvailable
    case invalidIndex
    case invalidCacheURL
   
}

extension PanoramaError: LocalizedError {
    
    /// String descriptions of each possible error value
    public var errorDescription: String? {
        switch self {
            
        case .urlParameterMissing:
            return "The url parameters do not contain a \"url\" key and value"
            
        case .couldNotCreateURLFromParameter:
            return "Unable to create a URL from the \"url\" value provided"
        
        case .assetIdParameterMissing:
            return "The url parameters do not contain an \"assetID\" key and value"
        
        case .tokenParameterMissing:
            return "The url parameters do not contain a \"token\" key and value"
            
        case .noImagesAvailable:
            return "No 360Scenes are available for the specified content item"
            
        case .queryItemsMissing:
            return "No query items are available in the received URL"
            
        case .invalidIndex:
            return "An invalid 360Scene index was requested"
            
        case .invalidCacheURL:
            return "An invalid panorama URL cache value was returned"
            
        }
    }
    
}

