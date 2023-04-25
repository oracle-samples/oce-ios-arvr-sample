// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI

/**
 Provides different layouts in based on the vertical size class of the device
 Uses a HStack for compact verticalSizeClass to keep content on the screen without having to scroll
 */
struct OrientationView<Content: View>: View {
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
      }

    var body: some View {
        Group {
            if verticalSizeClass == .compact {
                HStack(spacing:40) {
                    content
                }
            } else {
                VStack(spacing: 30) {
                    content
                }
            }
        }
    }
}

