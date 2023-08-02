// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI
import SceneKit
import Combine 
import ARDemoCommon

public struct PanoramaView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var model: PanoramaModel
    @State var currentSelection: String = "bar"
    @State var showMenu = false
    
    private var queryItems: [URLQueryItem]?
    
    var completion: (() -> Void)?

    public init(queryItems: [URLQueryItem]?, completion: @escaping () -> Void) {
        _model = StateObject(wrappedValue: PanoramaModel(queryItems: queryItems))
        self.queryItems = queryItems
        self.completion = completion
    }
    
    public var body: some View {
        
        ZStack {
            switch self.model.state {
            case .none:
                PanoramaNoneView
                
            case .downloading:
                CustomSpinner(labelText: "Downloading")
                
            case .building:
                CustomSpinner(labelText: "Building")
                
            case .creatingExperienceItem:
                CustomSpinner(labelText: "Creating Panorama Experience")
                
            case .error(let error):
                ErrorView(error)
                
            case .close:
                Text("Closing...").onAppear {
                    self.completion?()
                }
               
            case .done:
                PanoramaAvailableView
            }
            
        }
        .onAppear {
            self.model.send(.download)
        }
        .navigationBarHidden(true)
        .onChange(of: scenePhase) { newValue in
            if newValue == .active {
                if self.model.hasChanged(queryItems: self.queryItems) {
                    self.model.send(.reset(queryItems))
                }
            }
        }
    
    }

    @ViewBuilder
    var PanoramaAvailableView: some View {
        ZStack {

            SphericalViewContainer(currentItem: self.model.currentItem, currentImage: self.model.currentPanoramaImage)
                .edgesIgnoringSafeArea(.all)
            
            if self.model.fetchingNext {
                CustomSpinner(labelText: "Downloading")
            }
            
            VStack {
       
                CloseButton(showTitle: true)

                Spacer()
                
                PanoramaTitle(title: self.model.currentItem.title)
                    .frame(maxHeight: 50)
            }

        }
        .buttonStyle(.plain)
    }
    
    
    @ViewBuilder
    func CloseButton(showTitle: Bool = false) -> some View {
        
        HStack {
            
            if showTitle {
                ZStack {
                    
                    Color.black.opacity(0.3).cornerRadius(5)
                    
                    Button {
                        self.showMenu = true
                    } label: {
                        HStack {
                            Text(self.model.currentLocationName).bold()
                            Spacer()
                            if !self.model.locations.isEmpty {
                                Image(systemName: "arrowtriangle.down.fill")
                            }
                        }
                        .contentShape(Rectangle())
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    }
                   
                    .bottomDrawer(controlledBy: self.$showMenu) {
                        PanoramaLocationMenu().environmentObject(self.model)
                    }
                    .disabled(self.$model.locations.isEmpty)
                    .padding(.leading, 10)
                    
                }
                .frame(height: 44)
            }
            
            Spacer()
            
            ZStack {
                Color.black.opacity(0.1).cornerRadius(5)
                
                Button {
                    self.model.send(.close)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .frame(width: 44, height: 44)
            .padding(.trailing, 10)
        }
        
    }
    
    @ViewBuilder
    func ErrorView(_ error: Error) -> some View {
        ZStack {
            VStack {
                CloseButton(showTitle: false)

                Spacer()
            }
            
            Text("Error: \(error.localizedDescription)")
        }
    }
    
    @ViewBuilder
    var PanoramaNoneView: some View {
        VStack {
           
            CloseButton(showTitle: false)
            
            Spacer()
            Text("None")
            Spacer()
        }
    }
}

struct PanoramaTitle: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(
                    Color.black.opacity(0.3).cornerRadius(5)
                )
            
            Spacer()
            
        }
    }
}
