// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

/// OracleContentCore does not, by default, provide a logging implementation. It is the responsibility of the caller to provide it.
/// This class conforms to the `LoggingProvider` protocol and should be initialized as part of the onboarding process.
/// This requires setting OracleContentCore.Onboarding.logger to point to an instance of this class
public class MyLoggingProvider: LoggingProvider {
    public func logError(_ message: String, file: String, line: UInt, function: String) {
        print("AR DEMO ERROR: \(file): \(function): \(line): \(message)")
    }
    
    public func logNetworkResponseWithData(_ response: HTTPURLResponse?, data: Data?, file: String, line: UInt, function: String) {
        print("AR DEMO NETWORK RESPONSE: \(file): \(function): \(line): \(String(describing: response))")
    }
    
    public func logNetworkRequest(_ request: URLRequest?, session: URLSession?, file: String, line: UInt, function: String) {
        print("AR DEMO NETWORK REQUEST: \(file): \(function): \(line): \(String(describing: request))")
    }
    
    public func logDebug(_ message: String, file: String, line: UInt, function: String) {
        print("AR DEMO NETWORK DEBUG: \(file): \(function): \(line): \(String(describing: message))")
    }
    
    public static func setImplementation() {
        let myLogger = MyLoggingProvider()
        Onboarding.logger = myLogger
    }
}
