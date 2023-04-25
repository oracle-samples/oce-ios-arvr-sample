// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import UIKit
import ARDemoCommon

/**
 Information parsed from the URL received by the application. Defines the properties required for submitting requests to Oracle Content Management as well as the identifier of the content item to view as a panorama
 */
public struct PanoramaURLParameters {
    
    /// The host of the Oracle Content Management server to which requests will be submitted
    var demoType: SupportedDemos
    var ocmURL: URL
    var token: String
    var assetId: String
    
    init(host: String, ocmURL: URL, token: String, assetId: String) throws {
        
        guard !host.isEmpty else {
            throw PanoramaError.urlParameterMissing
        }
        
        guard !token.isEmpty else {
            throw PanoramaError.tokenParameterMissing
        }
        
        guard !assetId.isEmpty else {
            throw PanoramaError.assetIdParameterMissing
        }
        
        self.demoType = .panorama
        self.ocmURL = ocmURL
        self.token = token
        self.assetId = assetId
        
    }
    
    init(urlString: String, token: String, assetId: String) throws {
        guard let url = URL(string: urlString) else {
            throw PanoramaError.couldNotCreateURLFromParameter
        }
        
        try self.init(host: SupportedDemos.panorama.rawValue, ocmURL: url, token: token, assetId: assetId)
    }
    
    init(queryItems: [URLQueryItem]?) throws {
        
        guard let queryItems = queryItems,
              !queryItems.isEmpty
        else {
            throw PanoramaError.queryItemsMissing
        }

        guard let urlString = queryItems.first(where: { $0.name == "url"})?.value?.removingPercentEncoding else {
            throw PanoramaError.urlParameterMissing
        }
        
        guard let resolvedURL = URL(string: urlString) else {
            throw PanoramaError.couldNotCreateURLFromParameter
        }
    
        guard let token = queryItems.first(where: { $0.name == "token"})?.value,
              !token.isEmpty else {
            throw PanoramaError.tokenParameterMissing
        }
        
        guard let assetId = queryItems.first(where: { $0.name == "assetID"})?.value,
              !assetId.isEmpty else {
            throw PanoramaError.assetIdParameterMissing
        }
        
        self.demoType = .panorama
        self.ocmURL = resolvedURL
        self.token = token
        self.assetId = assetId
     
    }
    
    func submit() throws {
        
        var components = URLComponents(string: "com.oracle.ios.ardemo://panorama")
        components?.queryItems = [
            URLQueryItem(name: "url", value: self.ocmURL.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)),
            URLQueryItem(name: "token", value: self.token),
            URLQueryItem(name: "assetID", value: self.assetId)
        ]
        
        if let url = components?.url {
            UIApplication.shared.open(url)
            
            let foundItems = ARDemoPanoramaURLCache.instance.items.filter { URLComponents(url: $0, resolvingAgainstBaseURL: false) == components }
            if foundItems.isEmpty {
                ARDemoPanoramaURLCache.instance.items.append(url)
                ARDemoPanoramaURLCache.instance.write()
            }
        } else {
            throw PanoramaError.couldNotCreateURLFromParameter
        }
        
    }
}
