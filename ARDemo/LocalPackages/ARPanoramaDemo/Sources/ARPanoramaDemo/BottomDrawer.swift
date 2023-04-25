// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI

@available(iOS 15, *)
public extension View {

    /// Presents a bottomSheet when a binding to a Boolean value that you provide is true.
    func bottomDrawer<Content: View>(controlledBy: Binding<Bool>,
                                    detents: [UISheetPresentationController.Detent] = [.medium()],
                                    @ViewBuilder content: @escaping () -> Content) -> some View {
        background {
            Color.clear
                .onChange(of: controlledBy.wrappedValue) { show in
                    if show {
                        BottomDrawer.present(detents: detents) {
                            content()
                                .onDisappear {
                                    controlledBy.projectedValue.wrappedValue = false
                                }
                        }
                    }
                }
        }
    }
}

/// Originally created when the demo supported both iOS 15 and iOS16, so we could not take advantage of the new iOS16+ SwiftUI APIs to present a popover with specified detents
/// This struct wil handle presentation of a UISheetPresentationController in both iOS versions
struct BottomDrawer {

    /// Reference to the navigation controller which will be created and presented
    private static var navController: UINavigationController? = nil

    public static func dismiss() {
        navController?.dismiss(animated: true) {
            navController = nil
        }
    }

    /// Display the UISheetPresentationController in both iOS 15 and iOS 16
    /// - parameter detents: [UISheetPresentationController.Detent]
    /// - parameter contentView: The SwiftUI View to display in the popover
    fileprivate static func present<PresentationContentView: View>(detents: [UISheetPresentationController.Detent],
                                                                   @ViewBuilder _ contentView: @escaping () -> PresentationContentView) {
        // create a navigation controller to display
        let detailViewController = UIHostingController(rootView: contentView())
        let nav = UINavigationController(rootViewController: detailViewController)
        self.navController = nav

        nav.modalPresentationStyle = .pageSheet

        if let sheet = nav.sheetPresentationController {
            sheet.detents = detents
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.largestUndimmedDetentIdentifier = .none
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 5
            
        }

        UIApplication.shared.currentUIWindow()?.rootViewController?.present(nav, animated: true, completion: nil)
    }
}

