// Copyright (c) 2023, Oracle and/or its affiliates
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI
import Combine
import OCEDelivery
import RealityKit

@main
struct MainView: App {
 
    @ObservedObject var model: PlaceholderModel = PlaceholderModel()
  
    var body: some SwiftUI.Scene {
        
        WindowGroup {
            NavigationView {
                
                VStack {
                    switch self.model.demoType {
                        
                    case .mug:
                        NavigationLink("", isActive: self.$model.showMugView) {
                            MugView(queryItems: self.model.components?.queryItems) {
                                self.model.send(.reset)
                            }
                        }
                       
                    case .panorama:
                        NavigationLink("", isActive: self.$model.showPanoramaView) {
                            PVContainer(queryItems: self.model.components?.queryItems) {
                                self.model.send(.reset)
                            }
                        }
                        
                    default:
                        
                        NavigationLink("Mug Entry") {
                            MugEntryForm()
                        }
                        
                        Button {
//                            let url = URL(string:
//                                            "com.oracle.ios.ardemo://mug?url=https%3A//devpod.mycontentdemo.com&token=ccc41db1903f497a919196bdb1894184&assetId=CONT45988F303CAF4AF1864530984AE74CB3&imageId=CONTB96A99C9CB194299832C3E49EE864682&mugColor=0x84AFD9&textColor=0x050505&customText=You%20can%20twist%20perception")!
                            
                            let url = URL(string: "com.oracle.ios.ardemo://mug?url=https%3A//ocereferencegen2-oce0004.ocecdn.oraclecloud.com&token=858f74e11dbf4104b5a25b23cd95daf7&assetId=CORE4EDB5C481D98429D907A0CF3DF2898E7&imageId=CONT0CE9CEC147AE4228AB299693A9426CCD&mugColor=0x84AFD9&textColor=0x050505&customText=You%20can%20twist%20perception")!

                         
                            UIApplication.shared.open(url)
                            
                        } label: {
                            Text("Mug Demo")
                        }
                        
                        Button {
                            UIApplication.shared.open(URL(string:
                                                            "com.oracle.ios.ardemo://panorama?url=https%3A//devpod.mycontentdemo.com&token=ccc41db1903f497a919196bdb1894184&assetId=COREA886CF3F67EB4516B29B2EAC65FE534D")!)
                            
                        } label: {
                            Text("Panorama Demo")
                        }
                        
                        Button {
                            ARDemoCache.instance.clear()
                            ARDemoMugURLCache.instance.clear()
                        } label: {
                            Text("Clear Cache")
                        }

                       
                    }
                    
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .onOpenURL { url in
                let c = URLComponents(url: url, resolvingAgainstBaseURL: false)
                self.model.send(.openURL(c))
            }
            
        }
    }
    
    
}

enum PlaceholderModelAction {
    case openURL(URLComponents?)
    case reset
}

class PlaceholderModel: ObservableObject {
    @Published var demoType: SupportedDemos = .unknown
    @Published var showMugView = false
    @Published var showPanoramaView = false
    
    var components: URLComponents?
    
    func send(_ action: PlaceholderModelAction) {
        switch action {
            
        case .reset:
            self.demoType = .unknown
            self.components = nil
            self.showMugView = false
            self.showPanoramaView = false
            
        case .openURL(let components):
            self.components = components
            self.demoType = SupportedDemos(rawValue: components?.host)
            
            switch self.demoType {
            case .mug:
               
                ARDemoMugURLCache.instance.store(components?.url)
                self.showPanoramaView = false
                self.showMugView = true
                
            case .panorama:
                self.showMugView = false
                self.showPanoramaView = true
                
            default:
                self.showMugView = false
                self.showPanoramaView = false
            }
        }
    }
}

enum SupportedDemos: String, Identifiable {
    case unknown
    case mug
    case panorama
    case drinks
    
    var id: Self { self }
    
    init(rawValue: String?) {
        
        guard let value = rawValue else {
            self = .unknown
            return
        }
        
        switch value.lowercased() {
        case "mug":
            self = .mug
            
        case "panorama":
            self = .panorama
            
        case "drinks":
            self = .drinks
            
        default:
            self = .unknown
        }
    }
}

