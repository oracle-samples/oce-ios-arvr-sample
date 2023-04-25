// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI 

/// Fields in the entry form
class PanoramaEntryFields {
    var server: String = ""
    var token: String = ""
    var assetId: String = ""
    
    private var urlParameters: PanoramaURLParameters?
    
    func submit() throws {

            try self.urlParameters = PanoramaURLParameters(
                urlString: server,
                token: token,
                assetId: assetId)
            
            try self.urlParameters?.submit()
            
    }
}

class PanoramaEntryModel: ObservableObject {

    @Published var entryFields = PanoramaEntryFields()
    
    @Published var serverError = false
    @Published var tokenError = false
    @Published var assetIdError = false
    
    init() {

    }
    
    func submit() {
        
        self.resetErrors()
        
        do {
            try entryFields.submit()
        } catch PanoramaError.urlParameterMissing,
                PanoramaError.couldNotCreateURLFromParameter {
            serverError = true
        } catch PanoramaError.tokenParameterMissing {
            tokenError = true
        } catch PanoramaError.assetIdParameterMissing {
            assetIdError = true
        } catch {
            serverError = true
            tokenError = true
            assetIdError = true
        }
    }
    
    func resetErrors() {
        serverError = false
        tokenError = false
        assetIdError = false
    }
    
    func resetValues() {
        self.entryFields = PanoramaEntryFields()
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
        
    }
}
