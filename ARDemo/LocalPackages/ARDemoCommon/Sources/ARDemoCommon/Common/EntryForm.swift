// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI

/// Common Form used for entry forms 
public struct EntryForm<Content: View>: View {
    
    var content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        Form {
            content
        }
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .scrollContentBackground(.hidden)
    }
}


/// Common Section used for entry forms
public struct EntryTextSection: View {
    
    let title: String
    let prompt: String
    let field: Binding<String>
    let errorValue: Binding<Bool>
    
    public init(title: String, prompt: String, field: Binding<String>, errorValue: Binding<Bool>) {
        self.title = title
        self.prompt = prompt
        self.field = field
        self.errorValue = errorValue
    }
    
    public var body: some View {
        Section(header: Text(title)) {
            HStack {
                if errorValue.wrappedValue == true {
                    Image(systemName: "xmark.octagon.fill")
                }
                
                EntryTextField(prompt: prompt,
                               field: field,
                               errorValue: errorValue)
                
            }.foregroundColor(errorValue.wrappedValue ? .red : .primary)
        }
        .listRowBackground(Color(uiColor: ColorFunctions.rgbaColor(151, 151, 151, 0.1)))
    }
}

/// Common TextField used for entry forms
public struct EntryTextField: View {
    
    let prompt: String
    let field: Binding<String>
    let errorValue: Binding<Bool>
    
    public var body: some View {
        TextField(prompt, text: field)
            .onChange(of: field.wrappedValue) { newValue in
                errorValue.wrappedValue = false
            }
            .padding()
            
    }
}

/// Common button which submits the entry values
public struct EntrySubmitButton: View {
    
    var action: () -> Void
    
    public init(completion: @escaping () -> Void) {
        self.action = completion
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            Text("Test")
                .font(.system(size: 16, weight: .bold))
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color(uiColor: ColorFunctions.hexColor(0xBB0000)))
                .foregroundColor(.white)
        }
        .buttonStyle(.plain)
    }
}
