// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI

/// Custom progress spinner used by the demo UI
public struct CustomSpinner : View {
    @State private var isAnimating = false
    @State private var showProgress = false
    var labelText: String
    
    public init(labelText: String) {
        self.labelText = labelText
    }
    
    var foreverAnimation: Animation {
        Animation
            .linear(duration: 2.0)
            .repeatForever(autoreverses: false)
    }

    public var body: some View {
        VStack {
            Image(systemName: "arrow.2.circlepath")
                .font(.system(size: 80))
                .foregroundColor(Color(uiColor: ColorFunctions.hexColor(0xBB0000)))
                .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0.0))
                .animation(foreverAnimation, value: self.isAnimating)
                .onAppear { self.isAnimating = true }
                .onDisappear { self.isAnimating = false }
            
            Text(labelText)
        }
        .onAppear { self.showProgress = true }
    }
}

