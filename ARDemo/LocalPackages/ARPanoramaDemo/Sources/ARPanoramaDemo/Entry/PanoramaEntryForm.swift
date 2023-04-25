// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI
import ARDemoCommon

/**
 Entry form allowing you to provide the necessary parameters to test the panorama demo without having to scan a QR code
 
 Clicking the gear icon will open up a listing of previously used URLs .
 
 Once all required properties are entered, click the Test button at the bottom of the screen to load the model.
 */
public struct PanoramaEntryForm: View {
    
    @ObservedObject var model = PanoramaEntryModel()
    @State var showCached = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    public init() {
        UITableView.appearance().backgroundColor = .clear
    }
    
    public var body: some View {
        
        VStack {
            EntryForm {
                EntryTextSection(title: "Server",
                                 prompt: "Enter scheme , host and port",
                                 field: $model.entryFields.server,
                                 errorValue: $model.serverError)
                           
                EntryTextSection(title: "Channel Token",
                                 prompt: "Enter token",
                                 field: $model.entryFields.token,
                                 errorValue: $model.tokenError)
                  
                EntryTextSection(title: "Asset ID",
                                 prompt: "ID of the asset",
                                 field: $model.entryFields.assetId,
                                 errorValue: $model.assetIdError)
            }
            
            Spacer()
            
            EntrySubmitButton {
                self.model.submit()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .toolbar(content: {
            Button {
                self.showCached.toggle()
            } label: {
                Image(systemName: "gearshape.fill").font(.system(size: 16)).padding(.trailing, 10)
            }
            .buttonStyle(.plain)
        })
        .popover(isPresented: $showCached) {
            Text("Cached URLs")
            
            List(ARDemoPanoramaURLCache.instance.items, id: \.self) { url in
                Button {
                    self.model.populate(url)
                    self.showCached = false
                } label: {
                    Text(url.absoluteString)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    @ViewBuilder
    var backButton : some View { Button(action: {
        self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.backward") // BackButton Image
                    .font(.system(size: 16, weight: .bold))
                Text("Home") //translated Back button title
            }
            .foregroundColor(.primary)
        }
    }
}
