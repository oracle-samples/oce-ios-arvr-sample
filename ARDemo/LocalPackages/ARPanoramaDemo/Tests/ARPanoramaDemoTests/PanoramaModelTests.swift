// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
import OracleContentTest
@testable import ARPanoramaDemo

final class PanoramaModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}

extension PanoramaModelTests {
    
    /// Happy path test.
    /// QueryItems are fully populated
    /// state should equal .waitingToStart
    func testGoodURL() throws {
        let mugURL = URL(staticString: "com.oracle.ios.ardemo://panorama?url=https%3A%2F%2Fsomeserver.com&token=123&assetID=CORE456")
        let components = URLComponents(url: mugURL, resolvingAgainstBaseURL: false)
        
        let sut = PanoramaModel(queryItems: components?.queryItems)
        
        // nothing to do yet
        switch sut.state {
        case .none:
            break
            
        default:
            XCTFail("Incorrect state. Expected .waitingToStart")
        }
    }
    
    /// Validate that the state is set to error when nil query items are sent to the model
    func testNilQueryItems() throws {

        let sut = PanoramaModel(queryItems: nil)
        
        switch sut.state {
        case .error(let error):
            switch error {
            case PanoramaError.queryItemsMissing:
                break
                
            default:
                XCTFail("Expected .urlParameterMissing")
            }
            
        default:
            XCTFail("Expected error state")
        }
    }
    
    /// Validate that the state is set to error when empty query items are sent to the model
    func testEmptyQueryItems() throws {

        let sut = PanoramaModel(queryItems: [])
        
        switch sut.state {
        case .error(let error):
            switch error {
            case PanoramaError.queryItemsMissing:
                break
                
            default:
                XCTFail("Expected .urlParameterMissing")
            }
            
        default:
            XCTFail("Expected error state")
        }
    }
}
