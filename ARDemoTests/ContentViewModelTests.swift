// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest

@testable import ARDemo
@testable import ARMugDemo
@testable import ARPanoramaDemo
import OracleContentTest

/// Validate expected states when receiving a URL to process
/// The ContentViewModel's job is to determine which demo to display, based on the URL received.
/// Actual parsing of expected path components is the responsibility of each demo's model
/// - note: In tests, the term `"sut"` is used to represent `"System Under Test"`
class ContentViewModelTests: XCTestCase {

    override func setUpWithError() throws {
        ARDemoMugURLCache.instance.clear()
        ARDemoPanoramaURLCache.instance.clear()
    }

    override func tearDownWithError() throws {
        ARDemoMugURLCache.instance.clear()
        ARDemoPanoramaURLCache.instance.clear()
    }
}

// MARK: URL Tests
extension ContentViewModelTests {
    
    // Validate model behavior when a fully valid mug URL is received
    func testMugURL_Good_Full() throws {
        let mugURL = URL(staticString: "com.oracle.ios.ardemo://mug?url=https%3A%2F%2Fsomeserver.com&token=123&assetID=CORE456&imageID=CONT789D&mugColor=0x123123&textColor=0x050505&customText=Spaces%20used")
        let sut = ContentViewModel()
        
        sut.send(.openURL(mugURL))
        
        XCTAssertEqual(sut.demoType, .mug)
        XCTAssertTrue(sut.showMugView)
        XCTAssertFalse(sut.showPanoramaView)
        XCTAssertFalse(sut.showError)
        
        let urlCache = try XCTUnwrap(ARDemoMugURLCache.read())
        XCTAssertEqual(urlCache.count, 1)

        let panoramaCache = try XCTUnwrap(ARDemoPanoramaURLCache.read())
        XCTAssertTrue(panoramaCache.isEmpty)
        
    }
    
    // Validate model behavior when a mug URL is received which contains no path information
    // Although this will ultimately end up being a "bad" URL, that behavior will be enforced by the Mug model
    // The ContentViewModel's responsibility is to determine the process to invoke for further processing
    func testMugURL_Good_Incomplete() throws {
        let mugURL = URL(staticString: "com.oracle.ios.ardemo://mug")
        let sut = ContentViewModel()
        
        sut.send(.openURL(mugURL))
        
        XCTAssertEqual(sut.demoType, .mug)
        XCTAssertTrue(sut.showMugView)
        XCTAssertFalse(sut.showPanoramaView)
        XCTAssertFalse(sut.showError)
        
        let urlCache = try XCTUnwrap(ARDemoMugURLCache.read())
        XCTAssertEqual(urlCache.count, 1)
        
        let panoramaCache = try XCTUnwrap(ARDemoPanoramaURLCache.read())
        XCTAssertTrue(panoramaCache.isEmpty)
    }
    
    // Validate model behavior when a valid panorama URL is received
    func testPanoramaURL_Good_Full() throws {
        let panoramaURL = URL(staticString: "com.oracle.ios.ardemo://panorama?url=https%3A%2F%2Fsomeserver.com&token=123&assetID=CORE456")
        let sut = ContentViewModel()
        
        sut.send(.openURL(panoramaURL))
        
        XCTAssertEqual(sut.demoType, .panorama)
        XCTAssertTrue(sut.showPanoramaView)
        XCTAssertFalse(sut.showMugView)
        XCTAssertFalse(sut.showError)
        
        let urlCache = try XCTUnwrap(ARDemoPanoramaURLCache.read())
        XCTAssertEqual(urlCache.count, 1)
        
        let mugCache = try XCTUnwrap(ARDemoMugURLCache.read())
        XCTAssertTrue(mugCache.isEmpty)
        
    }
    
    // Validate model behavior when a panorama URL is received which contains no path information
    // Although this will ultimately end up being a "bad" URL, that behavior will be enforced by the Panorama model
    // The ContentViewModel's responsibility is to determine the process to invoke for further processing
    func testPanoramaURL_Good_Incomplete() throws {
        let panoramaURL = URL(staticString: "com.oracle.ios.ardemo://panorama")
        let sut = ContentViewModel()
        
        sut.send(.openURL(panoramaURL))
        
        XCTAssertEqual(sut.demoType, .panorama)
        XCTAssertTrue(sut.showPanoramaView)
        XCTAssertFalse(sut.showMugView)
        XCTAssertFalse(sut.showError)
        
        let urlCache = try XCTUnwrap(ARDemoPanoramaURLCache.read())
        XCTAssertEqual(urlCache.count, 1)
        
        let mugCache = try XCTUnwrap(ARDemoMugURLCache.read())
        XCTAssertTrue(mugCache.isEmpty)
    }
    
    // Validate invalid URL containing no host
    // Extracting query components from a URL without a host will result in a failure
    func testInvalidURL() throws {
        let badURL = URL(staticString: "com.oracle.ios.ardemo://")
        let sut = ContentViewModel()
        
        sut.send(.openURL(badURL))
        
        XCTAssertEqual(sut.demoType, .unknown)
        XCTAssertFalse(sut.showMugView)
        XCTAssertFalse(sut.showPanoramaView)
        XCTAssertTrue(sut.showError)
        XCTAssertFalse(sut.errorMessage.isEmpty)
        
        let mugCache = try XCTUnwrap(ARDemoMugURLCache.read())
        XCTAssertTrue(mugCache.isEmpty)
        
        let panoramaCache = try XCTUnwrap(ARDemoPanoramaURLCache.read())
        XCTAssertTrue(panoramaCache.isEmpty)
    }
    
    // Validate unknown demo type
    func testUnknownDemoTypeURL() throws {
        let badURL = URL(staticString: "com.oracle.ios.ardemo://foo")
        let sut = ContentViewModel()
        
        sut.send(.openURL(badURL))
        
        XCTAssertEqual(sut.demoType, .unknown)
        XCTAssertFalse(sut.showMugView)
        XCTAssertFalse(sut.showPanoramaView)
        XCTAssertTrue(sut.showError)
        XCTAssertFalse(sut.errorMessage.isEmpty)
        
        let mugCache = try XCTUnwrap(ARDemoMugURLCache.read())
        XCTAssertTrue(mugCache.isEmpty)
        
        let panoramaCache = try XCTUnwrap(ARDemoPanoramaURLCache.read())
        XCTAssertTrue(panoramaCache.isEmpty)
    }
}
