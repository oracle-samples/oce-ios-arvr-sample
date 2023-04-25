// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest

@testable import ARMugDemo 
import OracleContentTest

class CustomizableMugURLParametersTests: XCTestCase {

    let mugURL = URL(staticString: "com.oracle.ios.ardemo://mug?url=https%3A%2F%2Fsomeserver.com&token=123&assetID=CORE456&imageID=CONT789&mugColor=0x123123&textColor=0x050505&customText=Spaces%20used")
    
    override func setUpWithError() throws {
       
    }

    override func tearDownWithError() throws {
        
    }
}

// Initialization Tests
extension CustomizableMugURLParametersTests {
    func testGoodURL() throws {
        let components = URLComponents(url: mugURL, resolvingAgainstBaseURL: false)
        
        let sut = try MugURLParameters(queryItems: components?.queryItems)
        
        XCTAssertEqual(sut.demoType, .mug)
        try XCTAssertURLEqual(sut.ocmURL, URL(staticString: "https://someserver.com"))
        XCTAssertEqual(sut.token, "123")
        XCTAssertEqual(sut.assetId, "CORE456")
        XCTAssertEqual(sut.imageId, "CONT789")
        XCTAssertEqual(sut.mugColor, 0x123123)
        XCTAssertEqual(sut.textColor, 0x050505)
        XCTAssertEqual(sut.text, "Spaces used")

    }
    
    func testMissingURLParameter() throws {
        let badURL = URL(staticString: "com.oracle.ios.ardemo://mug?url=&token=123&assetID=CORE456&imageID=CONT789&mugColor=0x123123&textColor=0x050505&customText=Spaces%20used")
        let components = URLComponents(url: badURL, resolvingAgainstBaseURL: false)
        
        XCTAssertThrowsError( try MugURLParameters(queryItems: components?.queryItems), "Invalid Error Thrown") { error in
            switch error {
            case MugDemoError.urlParameterMissing:
                break
                
            default:
                XCTFail("Expected .urlParameterMissing")
            }
        }
    }
    
    func testMissingTokenParameter() throws {
        let badURL = URL(staticString: "com.oracle.ios.ardemo://mug?url=https%3A%2F%2Fsomeserver.com&token=&assetID=CORE456&imageID=CONT789&mugColor=0x123123&textColor=0x050505&customText=Spaces%20used")
        let components = URLComponents(url: badURL, resolvingAgainstBaseURL: false)
        
        XCTAssertThrowsError( try MugURLParameters(queryItems: components?.queryItems), "Invalid Error Thrown") { error in
            switch error {
            case MugDemoError.tokenParameterMissing:
                break
                
            default:
                XCTFail("Expected .tokenParameterMissing")
            }
        }
    }
    
    func testMissingAssetIdParameter() throws {
        let badURL = URL(staticString: "com.oracle.ios.ardemo://mug?url=https%3A%2F%2Fsomeserver.com&token=123&assetID=&imageID=CONT789&mugColor=0x123123&textColor=0x050505&customText=Spaces%20used")
        let components = URLComponents(url: badURL, resolvingAgainstBaseURL: false)
        
        XCTAssertThrowsError( try MugURLParameters(queryItems: components?.queryItems), "Invalid Error Thrown") { error in
            switch error {
            case MugDemoError.assetIdParameterMissing:
                break
                
            default:
                XCTFail("Expected .assetIdParameterMissing")
            }
        }
    }
    
    func testMissingImageIdParameter() throws {
        let badURL = URL(staticString: "com.oracle.ios.ardemo://mug?url=https%3A%2F%2Fsomeserver.com&token=123&assetID=CORE456&imageID=&mugColor=0x123123&textColor=0x050505&customText=Spaces%20used")
        let components = URLComponents(url: badURL, resolvingAgainstBaseURL: false)
        
        XCTAssertThrowsError( try MugURLParameters(queryItems: components?.queryItems), "Invalid Error Thrown") { error in
            switch error {
            case MugDemoError.imageIdParameterMissing:
                break
                
            default:
                XCTFail("Expected .imageIdParameterMissing")
            }
        }
    }
    
    func testMissingMugColorParameter() throws {
        let badURL = URL(staticString: "com.oracle.ios.ardemo://mug?url=https%3A%2F%2Fsomeserver.com&token=123&assetID=CORE456&imageID=CONT789&mugColor=&textColor=0x050505&customText=Spaces%20used")
        let components = URLComponents(url: badURL, resolvingAgainstBaseURL: false)
        
        XCTAssertThrowsError( try MugURLParameters(queryItems: components?.queryItems), "Invalid Error Thrown") { error in
            switch error {
            case MugDemoError.mugColorParameterMissing:
                break
                
            default:
                XCTFail("Expected .mugColorParameterMissing")
            }
        }
    }
    
    func testMissingTextColorParameter() throws {
        let badURL = URL(staticString: "com.oracle.ios.ardemo://mug?url=https%3A%2F%2Fsomeserver.com&token=123&assetID=CORE456&imageID=CONT789&mugColor=0x123123&textColor=&customText=Spaces%20used")
        let components = URLComponents(url: badURL, resolvingAgainstBaseURL: false)
        
        let sut = try MugURLParameters(queryItems: components?.queryItems)
        
        XCTAssertNil(sut.textColor)
        XCTAssertNotNil(sut.text)
        
    }
    
    func testMissingTextParameter() throws {
        let badURL = URL(staticString: "com.oracle.ios.ardemo://mug?url=https%3A%2F%2Fsomeserver.com&token=123&assetID=CORE456&imageID=CONT789&mugColor=0x123123&textColor=0x050505&customText=")
        let components = URLComponents(url: badURL, resolvingAgainstBaseURL: false)
        
        let sut = try MugURLParameters(queryItems: components?.queryItems)
        
        XCTAssertNotNil(sut.textColor)
        XCTAssertNil(sut.text)
        
    }
}
