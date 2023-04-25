// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
import OracleContentTest
@testable import ARPanoramaDemo

final class PanoramaURLParametersTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}

extension PanoramaURLParametersTests {
    func testGoodURL() throws {
        let urlString = URL(staticString: "com.oracle.ios.ardemo://panorama?url=https%3A%2F%2Fsomeserver.com&token=123&assetID=CORE456")
        let components = URLComponents(url: urlString, resolvingAgainstBaseURL: false)
        
        let sut = try PanoramaURLParameters(queryItems: components?.queryItems)
        
        XCTAssertEqual(sut.demoType, .panorama)
        try XCTAssertURLEqual(sut.ocmURL, URL(staticString: "https://someserver.com"))
        XCTAssertEqual(sut.token, "123")
    }
}

// MARK: URL Parmater Tests
extension PanoramaURLParametersTests {
    
    func testMissingURLParameter() throws {
        let badURL = URL(staticString: "com.oracle.ios.ardemo://panorama?token=123&assetID=CORE456")
        let components = URLComponents(url: badURL, resolvingAgainstBaseURL: false)
        
        XCTAssertThrowsError( try PanoramaURLParameters(queryItems: components?.queryItems), "Invalid Error Thrown") { error in
            switch error {
            case PanoramaError.urlParameterMissing:
                break
                
            default:
                XCTFail("Expected .urlParameterMissing")
            }
        }
    }
    
    func testBlankURLParameter() throws {
        let badURL = URL(staticString: "com.oracle.ios.ardemo://panorama?url=&token=123&assetID=CORE456")
        let components = URLComponents(url: badURL, resolvingAgainstBaseURL: false)
        
        XCTAssertThrowsError( try PanoramaURLParameters(queryItems: components?.queryItems), "Invalid Error Thrown") { error in
            switch error {
            case PanoramaError.couldNotCreateURLFromParameter:
                break
                
            default:
                XCTFail("Expected .urlParameterMissing")
            }
        }
    }
    
    func testMalformedURLParameter() throws {
        let badURL = URL(staticString: "com.oracle.ios.ardemo://panorama?url&token=123&assetID=CORE456")
        let components = URLComponents(url: badURL, resolvingAgainstBaseURL: false)
        
        XCTAssertThrowsError( try PanoramaURLParameters(queryItems: components?.queryItems), "Invalid Error Thrown") { error in
            switch error {
            case PanoramaError.urlParameterMissing:
                break
                
            default:
                XCTFail("Expected .assetIdParameterMissing")
            }
        }
    }
}

// MARK: Token Parameter Tests
extension PanoramaURLParametersTests {
    
    func testMissingTokenParameter() throws {
        let badURL = URL(staticString: "com.oracle.ios.ardemo://panorama?url=https%3A%2F%2Fsomeserver.com&assetID=CORE456")
        let components = URLComponents(url: badURL, resolvingAgainstBaseURL: false)
        
        XCTAssertThrowsError( try PanoramaURLParameters(queryItems: components?.queryItems), "Invalid Error Thrown") { error in
            switch error {
            case PanoramaError.tokenParameterMissing:
                break
                
            default:
                XCTFail("Expected .tokenParameterMissing")
            }
        }
    }
    
    func testMalformedTokenParameter() throws {
        let badURL = URL(staticString: "com.oracle.ios.ardemo://panorama?url=https%3A%2F%2Fsomeserver.com&token&assetID=CORE456")
        let components = URLComponents(url: badURL, resolvingAgainstBaseURL: false)
        
        XCTAssertThrowsError( try PanoramaURLParameters(queryItems: components?.queryItems), "Invalid Error Thrown") { error in
            switch error {
            case PanoramaError.tokenParameterMissing:
                break
                
            default:
                XCTFail("Expected .assetIdParameterMissing")
            }
        }
    }
    
    func testBlankTokenParameter() throws {
        let badURL = URL(staticString: "com.oracle.ios.ardemo://panorama?url=https%3A%2F%2Fsomeserver.com&token=&assetID=CORE456")
        let components = URLComponents(url: badURL, resolvingAgainstBaseURL: false)
        
        XCTAssertThrowsError( try PanoramaURLParameters(queryItems: components?.queryItems), "Invalid Error Thrown") { error in
            switch error {
            case PanoramaError.tokenParameterMissing:
                break
                
            default:
                XCTFail("Expected .assetIdParameterMissing")
            }
        }
    }
    
}

// MARK: AssetID Parameter Test
extension PanoramaURLParametersTests {
    
    func testMissingAssetIdParameter() throws {
        let badURL = URL(staticString: "com.oracle.ios.ardemo://panorama?url=https%3A%2F%2Fsomeserver.com&token=123")
        let components = URLComponents(url: badURL, resolvingAgainstBaseURL: false)
        
        XCTAssertThrowsError( try PanoramaURLParameters(queryItems: components?.queryItems), "Invalid Error Thrown") { error in
            switch error {
            case PanoramaError.assetIdParameterMissing:
                break
                
            default:
                XCTFail("Expected .assetIdParameterMissing")
            }
        }
    }
    
    func testMalformedAssetIDParameter() throws {
        let badURL = URL(staticString: "com.oracle.ios.ardemo://panorama?url=https%3A%2F%2Fsomeserver.com&token=123&assetID")
        let components = URLComponents(url: badURL, resolvingAgainstBaseURL: false)
        
        XCTAssertThrowsError( try PanoramaURLParameters(queryItems: components?.queryItems), "Invalid Error Thrown") { error in
            switch error {
            case PanoramaError.assetIdParameterMissing:
                break
                
            default:
                XCTFail("Expected .assetIdParameterMissing")
            }
        }
    }
    
    func testBlankAssetIDParameter() throws {
        let badURL = URL(staticString: "com.oracle.ios.ardemo://panorama?url=https%3A%2F%2Fsomeserver.com&token=123&assetID=")
        let components = URLComponents(url: badURL, resolvingAgainstBaseURL: false)
        
        XCTAssertThrowsError( try PanoramaURLParameters(queryItems: components?.queryItems), "Invalid Error Thrown") { error in
            switch error {
            case PanoramaError.assetIdParameterMissing:
                break
                
            default:
                XCTFail("Expected .assetIdParameterMissing")
            }
        }
    }
}
