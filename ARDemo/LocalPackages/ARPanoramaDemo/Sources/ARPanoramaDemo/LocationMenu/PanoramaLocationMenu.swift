// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI
import ARDemoCommon

struct PanoramaLocationMenu: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @EnvironmentObject var model: PanoramaModel
    
    var body: some View {
        VStack {
            HStack {
                Text("View Cafe")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                
                if self.verticalSizeClass == .compact {
                    
                    Spacer()
                    
                    Button {
                        UIApplication.shared.currentUIWindow()?.rootViewController?.dismiss(animated: true)
                    } label: {
                        Image(systemName: "xmark")
                    }.buttonStyle(.plain)
                }
            }
            .padding(.bottom, 20)
            
            ScrollView {
                ForEach(self.model.locations, id: \.identifier) { location in
                    Text(location.name).asPanoramaMenuButton {
                        self.model.send(.newLocation(location))
                    }.padding(.bottom, 10)
                }
            }
            
            
            Spacer()
        }
    }
    
}

struct PanoramaLocationMenuItem: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .foregroundColor(.white)
            .background(Color(uiColor: ColorFunctions.hexColor(0xBB0000)))
            .cornerRadius(5)
    }
}

struct PanoramaLocationMenuButton: ViewModifier {
    private var width: Double
    private var onSelect: (() -> Void)?
    private var dismissOnSelect: Bool = true
    
    init(_ width: Double? = nil, dismissOnSelect: Bool? = nil, onSelect: (() -> Void)?) {
        self.width = width ?? 300
        self.dismissOnSelect = dismissOnSelect ?? true
        self.onSelect = onSelect
    }
    
    func body(content: Content) -> some View {
        return Button {
            onSelect?()
            if self.dismissOnSelect {
                UIApplication.shared.currentUIWindow()?.rootViewController?.dismiss(animated: true )
            }
        } label: {
            content.asPanoramaMenuItem()
        }
        .frame(width: self.width)
    }
}

extension View {
    func asPanoramaMenuItem() -> some View {
        self.modifier(PanoramaLocationMenuItem())
    }
    
    func asPanoramaMenuButton(width: Double? = nil, dismissOnSelect: Bool? = nil, onSelect: (() -> Void)? = nil) -> some View {
        self.modifier(PanoramaLocationMenuButton(width, dismissOnSelect: dismissOnSelect, onSelect: onSelect))
    }
}
