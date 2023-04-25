// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import ARDemoCommon

/// When users scan a QR code, a custom URL is intercepted by the application
/// That URL is persisted so that users may revisit any of their previous choices without having to go through the web interface each time
public class ARDemoPanoramaURLCache: ObservableObject, Codable, URLCacheProtocol {
    
    public static var instance: URLCacheProtocol = ARDemoPanoramaURLCache()
    
    public static var fileLocation = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("ARDemoPanoramaURLCache.json")
    
    public var items: [URL]
    
    private init() {
        if let cache = Self.read() {
            self.items = cache
        } else {
            self.items = []
        }
    }
}
