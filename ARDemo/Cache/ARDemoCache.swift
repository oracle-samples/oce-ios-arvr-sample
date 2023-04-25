// Copyright (c) 2023, Oracle and/or its affiliates
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI

class ARDemoFileCache: ObservableObject, Codable {
    
    static var instance = ARDemoFileCache()
    
    static let fileLocation = FileManager.default
                                         .urls(for: .documentDirectory, in: .userDomainMask)[0]
                                         .appendingPathComponent("ARDemoCache.json")
    
    var items: [String: ARDemoCacheValue]
    
    private init() {
        if let cache = ARDemoFileCache.read() {
            self.items = cache
        } else {
            self.items = [:]
        }
    }
}

extension ARDemoFileCache {
    
    static func read() -> [String: ARDemoCacheValue]? {
            do {
                let data = try Data(contentsOf: ARDemoFileCache.fileLocation)
                let persistedValues = try JSONDecoder().decode([String: ARDemoCacheValue].self, from: data)
                return persistedValues
            } catch {
                print(error)
                return nil
            }
    }
    
    func write() {

        guard let data = try? JSONEncoder().encode(self.items) else { return }

            do {
                try data.write(to: ARDemoFileCache.fileLocation)
            } catch {
                print(error)
            }
        
    }
    
    func clear() {
        
        let jsonData = "{ }".data(using: .utf8)!
        do {
            try jsonData.write(to: ARDemoFileCache.fileLocation)
            self.items = [:]
            
        } catch {
            print(error)
        }
    }
}
