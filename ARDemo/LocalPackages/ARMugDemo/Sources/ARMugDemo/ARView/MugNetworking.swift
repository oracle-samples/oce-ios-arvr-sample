// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore
import OracleContentDelivery
import Combine

public protocol MugNetworkingProtocol {
    /**
     Fetches data from the Content Management server
     
     The Asset and Image are simultaneously requested. Once the asset has been retrieved, then the rendition is downloaded.
     The service returns once all three services have completed and the resulting MugMaterials have been created.
     
     - parameter customizableParameters: Defines the data necesary to customize a mug model
     - parameter cacheProvider: The cache provider to use while performing download operations
     - returns: AnyPublisher containing the Asset, the URL for the USDZ file and URL for the image to be applied
     */
    static func obtainServerData(
        using customizableParameters: MugURLParameters,
        cacheProvider: CacheProvider
    ) -> AnyPublisher<(Asset, DownloadResult<URL>, DownloadResult<URL>), Error>
}

/**
 Networking code that calls into the OracleContentDelivery APIs
 */
public enum MugNetworking: MugNetworkingProtocol {
    
    /**
     Fetches data from the Content Management server
     
     The Asset and Image are simultaneously requested. Once the asset has been retrieved, then the rendition is downloaded.
     The service returns once all three services have completed and the resulting MugMaterials have been created.
     
     - parameter customizableParameters: Defines the data necesary to customize a mug model
     - parameter cacheProvider: The cache provider to use while performing download operations
     - returns: AnyPublisher containing the Asset, the URL for the USDZ file and URL for the image to be applied
     */
    public static func obtainServerData(
        using customizableParameters: MugURLParameters,
        cacheProvider: CacheProvider
    ) -> AnyPublisher<(Asset, DownloadResult<URL>, DownloadResult<URL>), Error> {
        // asynchronous requests
        let asset        = self.fetchAssetInfo(customizableParameters)                                      // retrieve information about the asset
        let imageURL     = self.downloadDecal(customizableParameters, cacheProvider: cacheProvider)         // download the user-specified decal
        
        // synchronous request - executes as part of the fetchAssetInfo pipeline
        let renditionURL = asset.flatMap(self.downloadRendition(customizableParameters, cacheProvider))     // download the rendition of the model required for the demo
        
        // sink up after all calls are complete
        return Publishers.Zip3(asset, renditionURL, imageURL)
                         .eraseToAnyPublisher()
    }
}

extension MugNetworking {

    /**
     Retrieve the information about the Asset specified in the provided customizableParameters
     
     - parameter customizableParameters: Defines the data necesary to customize a mug model
     - returns: Future<Asset, Error>
     */
    internal static func fetchAssetInfo(_ customizableParameters: MugURLParameters) -> Future<Asset, Error> {
        
        return DeliveryAPI                                                         // namespace
            .readAsset(assetId: customizableParameters.assetId)                    // service
            .overrideURL(customizableParameters.ocmURL)                            // builder pattern - provide URL
            .channelToken(customizableParameters.token)                            // builder pattern - provide token
            .fetch()                                                               // invocation verb
    }
    
    /**
     Retrieve the native version of the asset that will be used as the mug decal - defined in the provided customizableParameters
     
     - parameter customizableParameters: Defines the data necesary to customize a mug model
     - parameter cacheProvider: The cache provider to use while performing download operations
     - returns: Future<DownloadResult<URL>, Error>
    
     */
    internal static func downloadDecal(
        _ customizableParameters: MugURLParameters,
        cacheProvider: CacheProvider
    ) -> Future<DownloadResult<URL>, Error> {
        
        return DeliveryAPI                                                         // namespace
            .downloadNative(identifier: customizableParameters.imageId,
                            cacheProvider: cacheProvider,
                            cacheKey: customizableParameters.imageId)              // service
            .overrideURL(customizableParameters.ocmURL)                            // builder pattern - provide URL
            .channelToken(customizableParameters.token)                            // builder pattern - provide token
            .download(progress: nil)                                               // invocation verb
    }
    
    /**
     Curry a function that takes MugURLParameters and CacheProvider into a function that takes an Asset.
     
     - parameter customizableParameters: Defines the data necesary to customize a mug model
     - parameter cacheProvider: The cache provider to use while performing download operations
     - returns: A curried function that takes an Asset and returns a Future<DownloadResult<URL>, Error>
     
     Having a curried function is not NECESSARY at all -  but it can make the call site where it is used much nicer when used as part of a Combine pipeline.
     
     For example:
     
     ```swift
     let renditionURL = asset.flatMap { foundAsset in
        callSomeFunction(foundAsset, otherParameter: foo, otherParameter: bar)
     }
     ```
     
     versus
     
     ```swift
     let renditionURL = asset.flatMap(curriedFunction(otherParameter: foo, otherParameter: bar)
     ```
     */
    internal static func downloadRendition(
        _ customizableParameters: MugURLParameters,
        _ cacheProvider: CacheProvider
    ) -> (Asset) -> Future<DownloadResult<URL>, Error> {
        return { asset in
            self._downloadRendition(asset, customizableParameters: customizableParameters, cacheProvider: cacheProvider)
        }
    }
    
    /**
     Download the USDZ rendition
     
     - parameter customizableParameters: Defines the data necesary to customize a mug model
     - parameter cacheProvider: The cache provider to use while performing download operations
     - returns: Future<DownloadResult<URL>, Error>
     */
    private static func _downloadRendition(
        _ asset: Asset,
        customizableParameters: MugURLParameters,
        cacheProvider: CacheProvider
    ) -> Future<DownloadResult<URL>, Error> {
        
        // The asset is a content item which contains several fields
        // The field named "model" represents the digital asset which represents the 3d model
        // The "model" digital asset contains a custom field named "usdz" which is the digital asset to download
        
        guard let contentItemModelAsset = try? asset.customField("model") as Asset,
              let usdzAsset = try? contentItemModelAsset.customField("usdz") as Asset else {
            return Future { promise in
                promise(.failure(MugDemoError.modelMissing))
            }
        }
    
        return DeliveryAPI                                                         // namespace
            .downloadNative(identifier: usdzAsset.identifier,                      // service
                            cacheProvider: cacheProvider,
                            cacheKey: usdzAsset.identifier)
            .overrideURL(customizableParameters.ocmURL)                            // builder pattern - provide URL
            .channelToken(customizableParameters.token)                            // builder pattern - provide token
            .download(progress: nil)                                               // invocation verb
        
    }
}
