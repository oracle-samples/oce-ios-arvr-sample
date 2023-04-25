// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest

@testable import ARMugDemo
import OracleContentTest

class MugNetworkModelTests: XCTestCase {
    override func setUpWithError() throws {
       
    }

    override func tearDownWithError() throws {
        
    }
}

// Initialization Tests
extension MugNetworkModelTests {
    
    /// Happy path test.
    /// QueryItems are fully populated
    /// state should equal .waitingToStart
    func testGoodURL() throws {
        let mugURL = URL(staticString: "com.oracle.ios.ardemo://mug?url=https%3A%2F%2Fsomeserver.com&token=123&assetID=CORE456&imageID=CONT789&mugColor=0x123123&textColor=0x050505&customText=Spaces%20used")
        let components = URLComponents(url: mugURL, resolvingAgainstBaseURL: false)
        
        let sut = MugModel(queryItems: components?.queryItems)
        
        // nothing to do yet
        switch sut.state {
        case .waitingToStart:
            break
            
        default:
            XCTFail("Incorrect state. Expected .waitingToStart")
        }
    }
    
    /// Validate that the state is set to error when the customizable parameters class throws an error
    func testCustomizableParametersFails() throws {
      
        /// missing url parameter
        let mugURL = URL(staticString: "com.oracle.ios.ardemo://mug?&token=123&assetID=CORE456&imageID=CONT789&mugColor=0x123123&textColor=0x050505&customText=Spaces%20used")
        
        let components = URLComponents(url: mugURL, resolvingAgainstBaseURL: false)
        
        let sut = MugModel(queryItems: components?.queryItems)
        
        switch sut.state {
        case .error(let error):
            switch error {
            case MugDemoError.urlParameterMissing:
                break
                
            default:
                XCTFail("Expected .urlParameterMissing")
            }
            
        default:
            XCTFail("Expected error state")
        }
    }
}
