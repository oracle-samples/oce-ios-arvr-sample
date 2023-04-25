// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
enum MugDemoError: Error {
    case primaryMeshMissing
    case imageMeshesMissing
    case imageMeshesEmpty
    case queryItemsMissing
    case urlParameterMissing
    case couldNotCreateURLFromParameter
    case tokenParameterMissing
    case assetIdParameterMissing
    case imageIdParameterMissing
    case mugColorParameterMissing
    case invalidColor
    case failureWritingTextImageToDisk
    case noMeshWithName(String)
    case couldNotLoadTextureFromURL
    case modelMissing
    
}

extension MugDemoError: LocalizedError {
    
    /// String descriptions of each possible error value
    public var errorDescription: String? {
        switch self {
            
        case .primaryMeshMissing:
            return "Custom field \"primarymeshname\" is missing from the asset"
            
        case .imageMeshesMissing:
            return "Custom field \"imagemeshnames\" is missing from the asset"
            
        case .imageMeshesEmpty:
            return "Custom field \"image_meshes\" is empty"
            
        case .queryItemsMissing:
            return "No query items are available in the received URL"
            
        case .urlParameterMissing:
            return "The url parameters do not contain a \"url\" key and value"
            
        case .couldNotCreateURLFromParameter:
            return "Unable to create a URL from the \"url\" value provided"
            
        case .tokenParameterMissing:
            return "The url parameters do not contain a \"token\" key and value"
            
        case .assetIdParameterMissing:
            return "The url parameters do not contain an \"assetID\" key and value"
            
        case .imageIdParameterMissing:
            return "The url parameters do not contain an \"imageID\" key and value"
            
        case .mugColorParameterMissing:
            return "The url parameters do not contain a \"mugColor\" key and value"
            
        case .failureWritingTextImageToDisk:
            return "Unable to write text image to disk. See log for more details."
            
        case .noMeshWithName(let meshName):
            return "Could not find a mesh with the name \"\(meshName)\""
            
        case .couldNotLoadTextureFromURL:
            return "Unable to load the material texture. See log for more details."
            
        case .invalidColor:
            return "Specified color is invalid"
            
        case .modelMissing:
            return "Custom field \"model\" is missing from the content item"
            
        }
    }
    
}

