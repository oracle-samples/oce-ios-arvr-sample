// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore


/// Errors that may be encountered when implementing your own `CacheProvider`
public enum ARDemoCacheError: Error {
    case cachedItemNotFound
    case unableToStoreDownloadInCache

    public var errorDescription: String? {
        switch self {
        case .cachedItemNotFound:
            return "The requested item was not found in the cache"
            
        case .unableToStoreDownloadInCache:
            return "The downloaded item could not be stored in the cache"
        }
    }
}

/// Values tracked by our file cache
/// Since our cache is utilizing Etags, we need to track the Etag value for each file file that we store
/// The cache itself looks up this value based on the identifier of the asset that we have downloaded
public class ARDemoFileCacheValue: Codable {
    var filename: String
    var etag: String?
    
    init(filename: String, etag: String?) {
        self.filename = filename
        self.etag = etag
    }
}

// MARK: My Existing Cache
/// This is the cache that is used to keep track of files which have been downloaded.
/// Each downloaded file will have a URL and ETag - persisted as part of an `ARDemoFileCache` object
/// Lookup of cached values is done via the asset's identifier value
public class ARDemoFileCache: Codable {
    
    public static var instance = ARDemoFileCache()
    
    /// For simplicity, the cache consists of a JSON file that keeps track of identifiers, filenames and etag values.
    /// The files themselves are stored in the `deviceCacheLocation`
    public static let cacheListing = FileManager.default
                                         .urls(for: .documentDirectory, in: .userDomainMask)[0]
                                         .appendingPathComponent("ARDemoCache.json")
    
    /// This is the location that downloaded files are stored on-device
    public static let deviceCacheLocation = FileManager
        .default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("savedFiles")

    /// The dictionary that associates file identifiers with corresponding filename and etag values
    var items: [String: ARDemoFileCacheValue]
    
    private init() {
        
        do {
            var isDir : ObjCBool = true
            if FileManager.default.fileExists(atPath: ARDemoFileCache.deviceCacheLocation.path, isDirectory: &isDir) {
                
                // This should not happen - where a FILE exists with the name of the expected FOLDER
                if !isDir.boolValue {
                    try FileManager.default.removeItem(at: ARDemoFileCache.deviceCacheLocation)
                    try FileManager.default.createDirectory(at: ARDemoFileCache.deviceCacheLocation, withIntermediateDirectories: true)
                }
            } else {
                // Create the folder into which we will persist downloaded files
                try FileManager.default.createDirectory(at: ARDemoFileCache.deviceCacheLocation, withIntermediateDirectories: true)
            }
        } catch let error {
            // We should never hit this code
            fatalError("Unexpected error initializing the device cache location. Error: \(error)")
        }
        
        if let cache = ARDemoFileCache.read() {
            self.items = cache
        } else {
            self.items = [:]
        }
    }
}

public extension ARDemoFileCache {
    
    /// Reads the persisted JSON file and returns the dictionary keyed by file identifier
    static func read() -> [String: ARDemoFileCacheValue]? {
        do {
            let data = try Data(contentsOf: ARDemoFileCache.cacheListing)
            let persistedValues = try JSONDecoder().decode([String: ARDemoFileCacheValue].self, from: data)
            return persistedValues
        } catch {
            Onboarding.logError("ARDemoError: Error reading the cache listing. \(error)")
            return nil
        }
    }
    
    /// Saves a downloaded file into the cache and updates the JSON listing associating the file identifier with the filename and etag
    static func saveDownloadedFile(key: String, etag: String, downloadedFileURL: URL) throws -> URL {
        
        // move the file from the tmp directory to the saved files directory
        let downloadedFilename = downloadedFileURL.lastPathComponent
        let newURL = self.deviceCacheLocation.appendingPathComponent(downloadedFilename)
        
        if FileManager.default.fileExists(atPath: newURL.path) {
            try FileManager.default.removeItem(at: newURL)
        }
        
        try FileManager.default.moveItem(at: downloadedFileURL, to: newURL)
       
        // persist the permanent file location in the cache
        ARDemoFileCache.instance.items[key] = ARDemoFileCacheValue(filename: downloadedFilename, etag: etag)

        ARDemoFileCache.instance.write()
        
        return newURL
    }
    
    /// Returns the URL for the cached file corresponding to the requested key
    static func cachedItem(key: String) -> URL? {
        if let foundValue = ARDemoFileCache.instance.items[key] {
            let url = ARDemoFileCache.deviceCacheLocation.appendingPathComponent(foundValue.filename)
            return url
        } else {
            return nil
        }
    }
    
    /// Persist the JSON file
    private func write() {
        
        guard let data = try? JSONEncoder().encode(self.items) else { return }
        
        do {
            try data.write(to: ARDemoFileCache.cacheListing)
        } catch {
            Onboarding.logError("ARDemoError: Error writing the cache listing to file. \(error)")
        }
        
    }
    
    /// Removes all cached files from device and the JSON dictionary
    func clear() {
        
        let jsonData = "{ }".data(using: .utf8)!
        do {
            try jsonData.write(to: ARDemoFileCache.cacheListing)
            self.items = [:]
            
            try FileManager.default.removeItem(at: ARDemoFileCache.deviceCacheLocation)
            try FileManager.default.createDirectory(at: ARDemoFileCache.deviceCacheLocation, withIntermediateDirectories: true)
            
        } catch {
            Onboarding.logError("ARDemoError: Error while attempting to clear the cache. \(error)")
        }
    }
}

// MARK: CacheProvider conformance
/**
 While this could be a separate object entirely, here we just conform our existing cache to the CacheProvider protocol.
 The purpose of the CacheProvider conformance is to allow the Oracle Content libraries to interface directly with our cache, saving lots of manual coding work
 */
extension ARDemoFileCache: CacheProvider {
    
    /// Since our cache is eTag-based, we want to always perform a fetch
    /// We will either get back the file requested with a 200 server response OR
    /// We will get back a 304 response - indicating that we need to serve the file from our cache
    public var cachePolicy: CachePolicy {
        .alwaysFetchWithCustomHeader
    }
   
    /// This cache utilizes Etags, so we need to ensure that the appropriate header value will be set in the request
    public func headerValues(for cacheKey: String) -> [String : String] {
       
        var etag = ""
        
        if let foundValue = ARDemoFileCache.instance.items[cacheKey],
           let foundEtag = foundValue.etag {
            etag = foundEtag
        }
        
        return ["If-None-Match": etag]
    }

    /// This method is not called by OracleContentCore because our cache policy is set to always perform a fetch
    public func find(key: String) -> URL? {
        return nil
    }
    
    /// This method is called from OracleContentCore when a 304 response was received.
    /// In this case, it is required that this class provide the previously downloaded URL associated with this key
    /// If for some reason the URL cannot be determined, throw our own error
    public func cachedItem(key: String) throws -> URL {
        if let url = ARDemoFileCache.cachedItem(key: key) {
            return url
        } else {
            throw ARDemoCacheError.cachedItemNotFound
        }
    }
    
    /// Called by OracleContentCore after a download has occurred. This allows us to store the URL in our cache and extract
    /// any necessary information out of the returned headers
    public func store(objectAt file: URL, key: String, headers: [AnyHashable : Any]) throws -> URL {
        
        let etagKey = headers.keys.compactMap { $0 as? String }.first { $0 == "Etag"}
        if let foundEtagKey = etagKey,
           let foundEtagValue = headers[foundEtagKey] as? String {
            
            let newURL = try ARDemoFileCache.saveDownloadedFile(key: key, etag: foundEtagValue, downloadedFileURL: file)
            return newURL
        } else {
            throw ARDemoCacheError.unableToStoreDownloadInCache
        }
    }
}
