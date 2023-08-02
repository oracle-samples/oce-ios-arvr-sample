//
//  SettingsView.swift
//  ARDemo
//
//  Created by Fred A. Brown on 6/26/23.
//

import Foundation
import SwiftUI
import ARMugDemo
import ARDemoCommon
import ARPanoramaDemo

struct SettingsView: View {
    @EnvironmentObject var model: ContentViewModel
    
    var body: some View {
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
        }
    }
}

// MARK: Standard buttons and Navigation Links
extension SettingsView {
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
extension SettingsView {
    
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
