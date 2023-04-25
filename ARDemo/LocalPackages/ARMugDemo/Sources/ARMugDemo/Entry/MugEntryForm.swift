// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI
import ARDemoCommon

/**
 Entry form allowing you to provide the necessary parameters to test the Mug demo without having to scan a QR code
 
 Clicking the gear icon will open up a listing of previously used URLs .
 
 Once all required properties are entered, click the Test button at the bottom of the screen to load the model.
 */
public struct MugEntryForm: View {
    
    @ObservedObject var model = MugEntryModel()
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
                                 errorValue: self.$model.serverError)
                
                EntryTextSection(title: "Channel Token",
                                 prompt: "Enter token",
                                 field: $model.entryFields.token,
                                 errorValue: $model.tokenError)
                
                EntryTextSection(title: "Asset ID", prompt: "ID of the asset",
                                 field: $model.entryFields.assetId,
                                 errorValue: $model.assetIdError)
                
                EntryTextSection(title: "Decal ID",prompt: "ID of the decal",
                                 field: $model.entryFields.imageId,
                                 errorValue: $model.imageIdError)
                
                EntryTextSection(title: "Mug Color", prompt: "0x000000",
                                 field: $model.entryFields.mugColor,
                                 errorValue: $model.mugColorError)
                
                EntryTextSection(title: "Optional Text", prompt: "Optional text to display",
                                 field: $model.entryFields.text,
                                 errorValue: $model.textError)
                
                EntryTextSection(title: "Optional Text Color", prompt: "0x000000",
                                 field: $model.entryFields.textColor,
                                 errorValue: $model.textColorError)
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
        .sheet(isPresented: $showCached) {
            Text("Cached URLs")
            
            List(ARDemoMugURLCache.instance.items, id: \.self) { url in
                Button {
                    self.model.populate(url)
                    self.showCached = false
                } label: {
                    MugURLCell(url)
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

/// Visual representation of the cached cell data
struct MugURLCell: View {
    
    var urlParams: MugURLParameters?
    
    init?(_ url: URL) {
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let queryItems = components?.queryItems else {
            return nil
        }
        
        guard let urlParams = try? MugURLParameters(queryItems: queryItems) else {
            return nil
        }
        
        self.urlParams = urlParams
      
    }
    
    var body: some View {
        VStack(alignment: .leading) {
                Text(self.urlParams?.ocmURL.absoluteString.removingPercentEncoding ?? "unknown")
                Text(self.urlParams?.token ?? "unknown")
                Text(self.urlParams?.assetId ?? "unknown")
                Text(self.urlParams?.imageId ?? "unknown")
                Text(self.urlParams?.mugColorHexString ?? "unknown")
                Text(self.urlParams?.text ?? "unknown")
                Text(self.urlParams?.textColorHexString ?? "unknown")
        }
        
    }
}
