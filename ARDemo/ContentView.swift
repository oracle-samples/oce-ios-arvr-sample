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
    
    var body: some View {
        
        ZStack {
            NavigationStack(path: self.$model.navigationPath) {
                
                // OrientationView allows for different layouts based on the vertical size class
                OrientationView {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                    
                    VStack(spacing: 20) {
                        MugDetailsButton
                        
                        PanoDetailsButton
                        
                        ClearCacheButton
                        
                        // These options will only appear when running on a simulator
                        SimulatorOnlyButtons
                    }
                }.navigationDestination(for: ContentViewNavigationPathType.self) { viewType in
                    switch viewType {
                    case .showMugView:
                        MugView(queryItems: self.model.components?.queryItems) {
                            self.model.send(.reset)
                        }
                        
                    case .showPanoramaView:
                        PanoramaView(queryItems: self.model.components?.queryItems) {
                            self.model.send(.reset)
                        }
                    }
                }
            }
        }
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

// MARK: Standard buttons and Navigation Links
extension ContentView {
    @ViewBuilder
    var MugDetailsButton: some View {
        NavigationLink {
            MugEntryForm()
        } label: {
            Label(title: {
                Text("MUG DETAILS")
            }, icon: {
                Image(systemName: "pencil")
            })
            .asDemoButtonLabel()
        }
        .asDemoButton()
    }
    
    @ViewBuilder
    var PanoDetailsButton: some View {
        NavigationLink {
            PanoramaEntryForm()
        } label: {
            Label(title: {
                Text("PANO DETAILS")
            }, icon: {
                Image(systemName: "pencil")
            })
            .asDemoButtonLabel()
        }
        .asDemoButton()
    }
    
    @ViewBuilder
    var ClearCacheButton: some View {
        Button {
            ARDemoFileCache.instance.clear()
            ARDemoMugURLCache.instance.clear()
            ARDemoPanoramaURLCache.instance.clear()
        } label: {
            Label(title: {
                Text("CLEAR CACHE")
            }, icon: {
                Image(systemName: "trash")
            })
            .asDemoButtonLabel()
        }
        .asDemoButton()
    }
}

// MARK: Simulator-only buttons
extension ContentView {
    
    /// If running on the simulator, then provide buttons which
    /// will allow for viewing a mug or panorama from a static URL.
    /// This allows for investigation and debugging without using a
    /// web server and viewing the URL created by a QR code
    @ViewBuilder
    var SimulatorOnlyButtons: some View {
        #if targetEnvironment(simulator)
            MugDemoButton
        
            PanoDemoButton
        
        #else
            EmptyView()
        
        #endif
    }

    @ViewBuilder
    var MugDemoButton: some View {
        
        Button {
            let urlString = ContentViewModel.mugDemoSimulatorURL

            UIApplication.shared.open(URL(string: urlString)!)

        } label: {
            Text("Mug Demo")
                .asSimulatorButtonText()
        }
        .asSimulatorButton()
    }
    
    @ViewBuilder
    var PanoDemoButton: some View {
        Button {
            
            let urlString = ContentViewModel.panoramaDemoSimulatorURL
                        
            UIApplication.shared.open(URL(string: urlString)!)

        } label: {
            Text("Panorama Demo")
                .asSimulatorButtonText()
        }
        .asSimulatorButton()
    }
    
}

// MARK: ViewModifiers
private struct DemoButtonModifier: ViewModifier {
    
    public func body(content: Content) -> some View {
        content
            .frame(maxWidth: 350, maxHeight: 50)
            .background(Color(uiColor: ColorFunctions.hexColor(0xBB0000)))
            .foregroundColor(Color.white)
    }
}

private struct DemoButtonLabelModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .bold))
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
    }
}

private struct SimulatorButtonModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(Color(uiColor: ColorFunctions.hexColor(0xBB0000)))
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
    }
}

private struct SimulatorButtonTextModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .frame(maxWidth: 350, maxHeight: 50)
            .background(Color.white)
            .border(Color(uiColor: ColorFunctions.hexColor(0xBB0000)))
            .buttonStyle(.plain)
    }
}

// MARK: View extensions for Buttons and Text
extension View {
    public func asDemoButton() -> some View {
        modifier(DemoButtonModifier())
    }
    
    public func asDemoButtonLabel() -> some View {
        modifier(DemoButtonLabelModifier())
    }
    
    public func asSimulatorButton() -> some View {
        modifier(SimulatorButtonModifier())
    }
    
    public func asSimulatorButtonText() -> some View {
        modifier(SimulatorButtonTextModifier())
    }
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

