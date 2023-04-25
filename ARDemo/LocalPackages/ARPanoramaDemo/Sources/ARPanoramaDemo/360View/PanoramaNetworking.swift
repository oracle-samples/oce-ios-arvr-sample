// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore
import OracleContentDelivery
import Combine

public protocol PanoramaNetworkingProtocol {
    /**
     Download the native rendition of an asset
     
     - parameter basedOn: The PanoramaURLParameters created from the URL received by the application
     - parameter identifier: The identifier of the asset to download
     - parameter cacheProvider: The CacheProvider to use during the download process
     - parameter cacheKey: The key for the asset in the cache
     - returns: Future<DownloadResult<URL>, Error>
     */
    static func downloadNative(
        basedOn panoramaParameters: PanoramaURLParameters,
        identifier: String,
        cacheProvider: CacheProvider,
        cacheKey: String
    ) -> Future<DownloadResult<URL>, Error>
    
    /**
     List the assets of type equal to "CSM-Location". Limited to 25 items
     
     - parameter basedOn: The PanoramaURLParameters created from the URL received by the application
     - returns: Future<Assets, Error>
     */
    static func listAssets(basedOn panoramaParameters: PanoramaURLParameters) -> Future<Assets, Error>
    
    /**
     Retrieve detailed information about an asset
     
     - parameter basedOn: The PanoramaURLParameters created from the URL received by the application
     - returns: Future<Asset, Error>
     */
    static func readAsset(basedOn panoramaParameters: PanoramaURLParameters) -> Future<Asset, Error>
}

/**
 Networking code that calls into the OracleContentDelivery APIs
 */
public enum PanoramaNetworking: PanoramaNetworkingProtocol {
    
    /**
     Download the native rendition of an asset
     
     - parameter basedOn: The PanoramaURLParameters created from the URL received by the application
     - parameter identifier: The identifier of the asset to download
     - parameter cacheProvider: The CacheProvider to use during the download process
     - parameter cacheKey: The key for the asset in the cache
     - returns: Future<DownloadResult<URL>, Error>
     */
    public static func downloadNative(
        basedOn panoramaParameters: PanoramaURLParameters,
        identifier: String,
        cacheProvider: CacheProvider,
        cacheKey: String
    ) -> Future<DownloadResult<URL>, Error> {
        DeliveryAPI
            .downloadNative(identifier: identifier, cacheProvider: cacheProvider, cacheKey: identifier)
            .overrideURL(panoramaParameters.ocmURL)
            .channelToken(panoramaParameters.token)
            .download(progress: nil)
    }
    
    /**
     List the assets of type equal to "CSM-Location". Limited to 25 items
     
     - parameter basedOn: The PanoramaURLParameters created from the URL received by the application
     - returns: Future<Assets, Error>
     */
    public static func listAssets(basedOn panoramaParameters: PanoramaURLParameters) -> Future<Assets, Error> {
        
        let initialNode = QueryNode.equal(field: "type", value: "CSM-Location")
        let builderNode = QueryBuilder(node: initialNode)
        
        return DeliveryAPI.listAssets()
            .overrideURL(panoramaParameters.ocmURL)
            .channelToken(panoramaParameters.token)
            .query(builderNode)
            .limit(25)
            .fetchNext()
    }
    
    /**
     Retrieve detailed information about an asset
     
     - parameter basedOn: The PanoramaURLParameters created from the URL received by the application
     - returns: Future<Asset, Error>
     */
    public static func readAsset(basedOn panoramaParameters: PanoramaURLParameters) -> Future<Asset, Error> {
        DeliveryAPI
            .readAsset(assetId: panoramaParameters.assetId)
            .overrideURL(panoramaParameters.ocmURL)
            .channelToken(panoramaParameters.token)
            .expand(.all)
            .fetch()
    }
}
