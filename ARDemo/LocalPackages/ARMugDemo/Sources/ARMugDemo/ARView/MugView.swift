// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI
import ARDemoCommon

/// View the downloaded mug model and apply the specified coloring, decals and text
public struct MugView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass: UserInterfaceSizeClass?
    
    @StateObject var model: MugModel
    
    public init(queryItems: [URLQueryItem]?, onClose: @escaping () -> Void) {
        _model = StateObject(wrappedValue: MugModel(queryItems: queryItems, onClose: onClose))
    }
    
    public var body: some View {
        Group {
            switch self.model.state {
            case .waitingToStart:
                WaitingToStartView
                
            case .done:
                DoneView
                
            case .downloading:
                CustomSpinner(labelText: "Downloading")
                
            case .loading:
                CustomSpinner(labelText: "Loading model")
                
            case .customizing:
                CustomSpinner(labelText: "Customizing model")
                
            case .error(let error):
                ErrorView(error)
                
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            self.model.send(.download)
        }
    }
    
}

extension MugView {
    @ViewBuilder
    var WaitingToStartView: some View {
        VStack {
            HStack {
                Spacer()
                CloseButton
            }
            
            Spacer()
            Text("Waiting to start")
            Spacer()
        }
    }
    
    @ViewBuilder
    var DoneView: some View {
        ZStack {
            ARViewContainer()
                .environmentObject(self.model)
                .edgesIgnoringSafeArea(.all)

            VStack {
               
                HStack {
                       
                    Spacer()
                    
                    CloseButton
                        .padding(.trailing, 10)
                        .padding(.top, self.verticalSizeClass == .compact ? 10 : 0)
                }
                
                Spacer()
                
                HStack {
                    MugTitle(customizableMaterials: self.model.customizableMaterials)
                    
                    Spacer()
                }
                .edgesIgnoringSafeArea(.bottom)
                .padding(.bottom, self.verticalSizeClass == .compact ? 10 : 20)
            }

        }
    }
    
    @ViewBuilder
    var CloseButton: some View {
        
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
    }
    
    @ViewBuilder
    func ErrorView(_ error: Error) -> some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    CloseButton
                }
                
                Spacer()
            }
            
            Text("Error: \(error.localizedDescription)")
        }
    }
}

struct MugTitle: View {
    let customizableMaterials: MugMaterials
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text(customizableMaterials.productName!.uppercased())
                .font(.system(size: 16, weight: .bold))
            
            if customizableMaterials.productName != nil {
                if customizableMaterials.price != nil {
                    Text("\(customizableMaterials.price!) ")
                        .font(.system(size: 12, weight: .bold))
                        
        
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 30)
        .background(
            Color.black.opacity(0.1).cornerRadius(5)
        )
        .foregroundColor(.white)
    }
}

#if DEBUG
struct MugMain_Previews : PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue.opacity(0.3)
            
            MugView(queryItems: nil, onClose: {}).CloseButton
        }
       
    }
}
#endif
