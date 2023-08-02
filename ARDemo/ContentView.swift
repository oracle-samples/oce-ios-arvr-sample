// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI
import ARMugDemo
import ARDemoCommon
import ARPanoramaDemo

/**
 The visible UI seen when starting the application
 
 When running on a simulator, two additional buttons allow for testing out the Mug and Panorama demos without having to scan a QR code
 */
struct ContentView: View {
    @StateObject var model: ContentViewModel = ContentViewModel()
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
            
        NavigationStack(path: self.$model.navigationPath) {
            ZStack {
                
                HStack {
                    Spacer()
                    
                    VStack {
                        Image(systemName: "gear")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                self.model.send(.showSettings)
                            }
                        
                        Spacer()
                    }
                }.padding(.trailing, 10)
                
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 400, height: 300)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
            }
            .navigationDestination(for: ContentViewNavigationPathType.self) { viewType in
                switch viewType {
                case .showMugView:
                    MugView(queryItems: self.model.components?.queryItems) {
                        self.model.send(.reset)
                    }
                    
                case .showPanoramaView:
                    PanoramaView(queryItems: self.model.components?.queryItems) {
                        self.model.send(.reset)
                    }
                    
                case .showSettings:
                    SettingsView()
                }
            }
        }
        .environmentObject(self.model)
        .alert(self.model.errorMessage, isPresented: self.$model.showError) {
            Button("OK", role: .cancel) { }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .onOpenURL { url in
            self.model.send(.openURL(url))
        }
    }
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

