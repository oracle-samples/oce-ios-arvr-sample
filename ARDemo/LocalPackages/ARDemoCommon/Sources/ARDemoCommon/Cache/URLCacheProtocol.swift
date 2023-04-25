// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Defines the structure required by conforming caches to persist URLs
/// The demo application is designed to be part of a full experience where the user does something on the web client, generates a QR code and scans it.
/// When the QR code is scanned, this demo application is started and objects are retrieved.
///
/// As an aid to users, each unique URL that comes from a QR code is persisted in cache.
/// Each URL may be retrieved and displayed in an editable format so that users can try various modifications without having to start back at the web client
///
/// The `ARDemoPanoramaURLCache` and `ARDemoMugURLCache` objects conform to this protocol
///
/// - note: This protocol is not related at all to the cache used to persist downloaded objects.
/// 
public protocol URLCacheProtocol {
    static var instance: URLCacheProtocol { get }
    static var fileLocation: URL  { get }

    /// In-memory representation of the cache
    var items: [URL]  { get set }

    /// Read the contains of the URL cache
    static func read() -> [URL]?
    
    /// Persist the in-memory representation of the cache to disk
    func write()
    
    /// Remove all URL entries from the cache
    mutating func clear()
    
    /// Add a new URL to the cache
    mutating func store(_ url: URL?)
}

public extension URLCacheProtocol {
    
    static func read() -> [URL]? {
        
        let data: Data
        do {
            data = try Data(contentsOf: Self.fileLocation)
        } catch {
            print(error)
            return nil
        }
        
        let persistedValues = try? JSONDecoder().decode([URL].self, from: data)
        return persistedValues
    }
    
    func write() {
        
        guard let data = try? JSONEncoder().encode(self.items) else { return }
        
        do {
            try data.write(to: Self.fileLocation)
        } catch {
            print(error)
        }
    }
    
    mutating func clear() {
        let jsonData = "[]".data(using: .utf8)!
        do {
            try jsonData.write(to: Self.fileLocation)
            self.items = []
            
        } catch {
            print(error)
        }
    }
    
    mutating func store(_ url: URL?) {
        
        guard let url = url else { return }
        
        let foundItem = self.items.first { $0 == url }
        if foundItem == nil {
            self.items.append(url)
            self.write()
        }
    }
}
