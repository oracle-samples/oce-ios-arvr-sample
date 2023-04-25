// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI
import ARDemoCommon

/**
 The main entry point of the application
 */
@main
struct MainView: App {
    
    var body: some SwiftUI.Scene {
        WindowGroup {
 
            ContentView()
                .onAppear {
                    // Tell OracleContentCore to use my logging provider implementation
                    MyLoggingProvider.setImplementation()
                }
            
        }
    }
}
