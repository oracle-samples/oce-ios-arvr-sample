// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI

/// The field names in the entry form
enum FieldNames: String, CaseIterable {
    case server
    case token
    case assetID
    case imageID
    case mugColor
    case text
    case textColor
}

/// The field values in the entry form
class EntryFields {
    var server: String = ""
    var token: String = ""
    var assetId: String = ""
    var imageId: String = ""
    var mugColor: String = ""
    var text: String = ""
    var textColor: String = ""
    
    private var urlParameters: MugURLParameters?

    func submit() throws {
        
        try self.urlParameters = MugURLParameters(
            ocmURL: server,
            token: token,
            assetId: assetId,
            imageId: imageId,
            mugColor: mugColor,
            text: text,
            textColor: textColor)
        
        try self.urlParameters?.submit()
        
    }
}

class MugEntryModel: ObservableObject {
    
    @Published var entryFields = EntryFields()
    
    @Published var serverError = false
    @Published var tokenError = false
    @Published var assetIdError = false
    @Published var imageIdError = false
    @Published var mugColorError = false
    @Published var textError = false
    @Published var textColorError = false
    
    init() {

    }
    
    func submit() {
        
        self.resetErrors()
        
        do {
            try entryFields.submit()
        } catch MugDemoError.urlParameterMissing,
                MugDemoError.couldNotCreateURLFromParameter {
            serverError = true
        } catch MugDemoError.tokenParameterMissing {
            tokenError = true
        } catch MugDemoError.assetIdParameterMissing {
            assetIdError = true
        } catch MugDemoError.imageIdParameterMissing {
            imageIdError = true
        } catch MugDemoError.mugColorParameterMissing {
            mugColorError = true
        } catch {
            serverError = true
            tokenError = true
            assetIdError = true
            imageIdError = true
            mugColorError = true
            textError = true
            textColorError = true
        }
    }
    
    func resetErrors() {
        serverError = false
        tokenError = false
        assetIdError = false
        imageIdError = false
        mugColorError = false
        textError = false
        textColorError = false
    }
    
    func resetValues() {
        self.entryFields = EntryFields()
    }
    
    func urlParms(_ url: URL) -> MugURLParameters? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let queryItems = components?.queryItems else {
            return nil
        }
        
        return try? MugURLParameters(queryItems: queryItems)
    }
    
    func populate(_ url: URL) {
        
        self.resetErrors()
        self.resetValues()
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let queryItems = components?.queryItems else {
            return
        }
        
        guard let urlString = queryItems.first(where: { $0.name == "url"})?.value?.removingPercentEncoding else {
            self.serverError = true
            return
        }
        self.entryFields.server = urlString
        
    
        guard let token = queryItems.first(where: { $0.name == "token"})?.value else {
            self.tokenError = true
            return
        }
        self.entryFields.token = token
        
        guard let assetId = queryItems.first(where: { $0.name == "assetID"})?.value else {
            self.assetIdError = true
            return
        }
        self.entryFields.assetId = assetId
        
        guard let imageId = queryItems.first(where: { $0.name == "imageID"})?.value else {
            self.imageIdError = true
            return
        }
        self.entryFields.imageId = imageId
              
        guard let mugColorString = queryItems.first(where: { $0.name == "mugColor"})?.value else {
            self.mugColorError = true
            return
        }
        self.entryFields.mugColor = mugColorString
        
        let text = queryItems.first(where: { $0.name == "customText"})?.value?.removingPercentEncoding
        self.entryFields.text = text ?? ""
            
        if let textColorString = queryItems.first(where: { $0.name == "textColor"})?.value {
            self.entryFields.textColor = textColorString
        }
    }
}
