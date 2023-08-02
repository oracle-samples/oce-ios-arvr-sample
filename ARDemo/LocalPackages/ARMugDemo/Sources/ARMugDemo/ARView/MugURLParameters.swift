// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI
import ARDemoCommon

public class MugURLParameters: Equatable {
    public static func == (lhs: MugURLParameters, rhs: MugURLParameters) -> Bool {
        return lhs.demoType == rhs.demoType &&
        lhs.ocmURL == rhs.ocmURL &&
        lhs.token == rhs.token &&
        lhs.assetId == rhs.assetId &&
        lhs.imageId == rhs.imageId &&
        lhs.mugColor == rhs.mugColor &&
        lhs.text == rhs.text &&
        lhs.textColor == rhs.textColor
    }
    
    var demoType: SupportedDemos
    var ocmURL: URL
    var token: String
    var assetId: String
    var imageId: String
    var mugColor: Int = 0
    var text: String?
    var textColor: Int?
    
    var mugColorHexString: String = ""
    var textColorHexString: String = ""
    
    init(ocmURL: String, token: String, assetId: String, imageId: String, mugColor: String, text: String?, textColor: String?) throws {
        self.demoType = .mug
        let tempURL = ocmURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let tempMugColor = mugColor.trimmingCharacters(in: .whitespacesAndNewlines)
        let tempTextColor = textColor?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        self.token = token.trimmingCharacters(in: .whitespacesAndNewlines)
        self.assetId = assetId.trimmingCharacters(in: .whitespacesAndNewlines)
        self.imageId = imageId.trimmingCharacters(in: .whitespacesAndNewlines)
        self.text = text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if tempURL.isEmpty { throw MugDemoError.urlParameterMissing }
        guard let resolvedURL = URL(string: tempURL) else {
            throw MugDemoError.couldNotCreateURLFromParameter
        }
        self.ocmURL = resolvedURL
        
        if self.token.isEmpty { throw MugDemoError.tokenParameterMissing }
        if self.assetId.isEmpty { throw MugDemoError.assetIdParameterMissing }
        if self.imageId.isEmpty { throw MugDemoError.imageIdParameterMissing }
        
        if tempMugColor.isEmpty {
            throw MugDemoError.mugColorParameterMissing
        } else {
            self.mugColor = try colorFrom(tempMugColor)
            self.mugColorHexString = tempMugColor
        }
        
        if let foundTextColor = tempTextColor,
           !foundTextColor.isEmpty {
            self.textColor = try colorFrom(foundTextColor)
            self.textColorHexString = foundTextColor
        }
    }
    
    init(queryItems: [URLQueryItem]?) throws {
        
        guard let queryItems = queryItems,
              !queryItems.isEmpty
        else {
            throw MugDemoError.queryItemsMissing
        }

        guard let urlString = queryItems.first(where: { $0.name == "url"})?.value?.removingPercentEncoding,
              !urlString.isEmpty else {
            throw MugDemoError.urlParameterMissing
        }
        
        guard let resolvedURL = URL(string: urlString) else {
            throw MugDemoError.couldNotCreateURLFromParameter
        }
    
        guard let token = queryItems.first(where: { $0.name == "token"})?.value,
              !token.isEmpty else {
            throw MugDemoError.tokenParameterMissing
        }
        
        guard let assetId = queryItems.first(where: { $0.name == "assetID"})?.value,
              !assetId.isEmpty else {
            throw MugDemoError.assetIdParameterMissing
        }
        
        guard let imageId = queryItems.first(where: { $0.name == "imageID"})?.value,
              !imageId.isEmpty else {
            throw MugDemoError.imageIdParameterMissing
        }
              
        guard let mugColorString = queryItems.first(where: { $0.name == "mugColor"})?.value,
              !mugColorString.isEmpty else {
            throw MugDemoError.mugColorParameterMissing
        }
        
        var text = queryItems.first(where: { $0.name == "customText"})?.value?.removingPercentEncoding
        if let foundText = text,
           foundText.isEmpty {
            text = nil
        }
            
        var textColor: Int?
        if let textColorString = queryItems.first(where: { $0.name == "textColor"})?.value {
            if textColorString.starts(with: "0x") {
                let x = textColorString.dropFirst(2)
                let y = String(x)
                textColor = Int(y, radix: 16)
                self.textColorHexString = textColorString
            }
        }
        
        var mugColor: Int = 0
        if mugColorString.starts(with: "0x") {
            let x = mugColorString.dropFirst(2)
            let y = String(x)
            mugColor = Int(y, radix: 16) ?? 0
        }
        
        self.demoType = .mug
        self.ocmURL = resolvedURL
        self.token = token
        self.assetId = assetId
        self.imageId = imageId
        self.text = text
        self.mugColor = mugColor
        self.textColor = textColor
        self.mugColorHexString = mugColorString
       
    }
    
    func colorFrom(_ enteredValue: String) throws -> Int {
        if enteredValue.starts(with: "0x") {
            let x = enteredValue.dropFirst(2)
            let y = String(x)
            
            let colorValue = Int(y, radix: 16)
            if colorValue == nil {
                throw MugDemoError.invalidColor
            } else {
                return colorValue!
            }
        } else {
            throw MugDemoError.invalidColor
        }
    }
    
    func submit() throws {
        
        var components = URLComponents(string: "com.oracle.ios.ardemo://mug")
        components?.queryItems = [
            URLQueryItem(name: "url", value: self.ocmURL.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)),
            URLQueryItem(name: "token", value: self.token),
            URLQueryItem(name: "assetID", value: self.assetId),
            URLQueryItem(name: "imageID", value: self.imageId),
            URLQueryItem(name: "mugColor", value: self.mugColorHexString),
            URLQueryItem(name: "customText", value: self.text ?? ""),
            URLQueryItem(name: "textColor", value: self.textColorHexString)
        ]
        
        if let url = components?.url {
            // send the URL to our application so that it may be processed just like it would if we had scanned a QR code
            UIApplication.shared.open(url)
            
            let foundItems = ARDemoMugURLCache.instance.items.filter { URLComponents(url: $0, resolvingAgainstBaseURL: false) == components }
            if foundItems.isEmpty {
                ARDemoMugURLCache.instance.items.append(url)
                ARDemoMugURLCache.instance.write()
            }
        } else {
            throw MugDemoError.couldNotCreateURLFromParameter
        }
        
    }
}
