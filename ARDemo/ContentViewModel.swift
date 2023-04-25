// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import ARDemoCommon
import ARMugDemo
import ARPanoramaDemo

/**
 Actions supported by the ContentViewModel
 */
enum ContentViewAction {
    case openURL(URL)
    case reset
}

/**
 Used provide navigation paths
 */
enum ContentViewNavigationPathType {
    // causes the AR Mug Demo to be displayed
    case showMugView
    
    // causes the AR Panorama Demo to be displayed
    case showPanoramaView
}

/**
 Provides state management for the Content View
 */
class ContentViewModel: ObservableObject {
    @Published var navigationPath: [ContentViewNavigationPathType] = []
    @Published var demoType: SupportedDemos = .unknown
    @Published var showMugView = false
    @Published var showPanoramaView = false
    @Published var errorMessage = ""
    @Published var showError = false
    
    var components: URLComponents?
    
    /// Reads the scheme, host, token and asset ID values to use for simulator-only runs
    static var demoParameters: DemoParameters = {
       
            guard let filePath = Bundle.main.path(forResource: "DemoParameters", ofType: "json"),
                  let data = FileManager.default.contents(atPath: filePath) else {
                return DemoParameters()
            }
            
            guard let credentials = try? JSONDecoder().decode(DemoParameters.self, from: data) else {
                return DemoParameters()
            }
            
            return credentials
    }()
    
    /// Used in simulator runs only. Formats a string that will eventually become a URL. This string mimics the format of the
    /// URL received from the web client when you scan a QR code for the mug demo
    static var mugDemoSimulatorURL: String = {
        let parameters = ContentViewModel.demoParameters
        
        let urlString = "com.oracle.ios.ardemo://mug?url=\(parameters.scheme)%3A%2F%2F\(ContentViewModel.demoParameters.host)&token=\(parameters.channelToken)&assetID=\(parameters.mugAssetID)&mugColor=0x84AFD9&imageID=\(parameters.mugDecalID)&customText=You%20can%20twist%20perception&textColor=0x050505"
        
        return urlString 
    }()
    
    /// Used in simulator runs only. Formats a string that will eventually become a URL. This string mimics the format of the
    /// URL received from the web client when you scan a QR code for the panorama demo
    static var panoramaDemoSimulatorURL: String = {
        
        let parameters = ContentViewModel.demoParameters
        
        let urlString = "com.oracle.ios.ardemo://panorama?url=\(parameters.scheme)%3A%2F%2F\(parameters.host)&token=\(parameters.channelToken)&assetID=\(parameters.panoramaAssetID)"
        
        return urlString 
    }()
    
    func send(_ action: ContentViewAction) {
        switch action {
            
        case .reset:
            self.demoType = .unknown
            self.components = nil
            self.showMugView = false
            self.showPanoramaView = false
            self.navigationPath.removeAll()
            
        case .openURL(let url):
            
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                self.showMugView = false
                self.showPanoramaView = false
                self.errorMessage = "Invalid URL received. \(url.absoluteString)"
                self.showError = true
                return 
            }
            
            self.components = components
            self.demoType = SupportedDemos(rawValue: components.host)
            
            switch self.demoType {
            case .mug:
                ARDemoMugURLCache.instance.store(components.url)
                self.showPanoramaView = false
                self.showMugView = true
                self.errorMessage = ""
                self.showError = false
                self.navigationPath = [.showMugView]
                
            case .panorama:
                ARDemoPanoramaURLCache.instance.store(components.url)
                self.showMugView = false
                self.showPanoramaView = true
                self.showError = false
                self.errorMessage = ""
                self.navigationPath = [.showPanoramaView]
                
            default:
                self.showMugView = false
                self.showPanoramaView = false
                self.errorMessage = "Unable to open URL for demo type \"\(self.demoType.rawValue)\""
                self.showError = true
                self.navigationPath.removeAll()
            }
        }
    }
}

struct DemoParameters: Codable {
    var scheme: String = ""
    var host: String = ""
    var channelToken: String = ""
    var mugAssetID: String = ""
    var mugDecalID: String = ""
    var panoramaAssetID: String = ""
}
