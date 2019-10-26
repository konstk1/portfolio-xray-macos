//
//  portfolio_xray_macosTests.swift
//  portfolio-xray-macosTests
//
//  Created by Konstantin Klitenik on 10/26/19.
//  Copyright © 2019 KK. All rights reserved.
//

import XCTest
import Combine
@testable import portfolio_xray_macos

class portfolio_xray_macosTests: XCTestCase {
    let ms = MorningStar()
    
    var requests: Set<AnyCancellable> = []

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFindFundEntity() {
        let expect = self.expectation(description: "Find sec")
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        ms.findEntity(ticker: "VFIAX").sink(receiveCompletion: { (_) in
            print("Done")
            expect.fulfill()
        }) { (result) in
            print(result!)
            XCTAssert(result?.ticker == "VFIAX", "Ticker doesn't match")
            XCTAssert(result?.exchange == "XNAS", "Incorrect exchange info")
            XCTAssert(result?.securityType == "FO", "Incorrect security type")
        }.store(in: &requests)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testFindFundId() {
        let expect = self.expectation(description: "Find sec")
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        ms.findEntity(ticker: "VFIAX").sink(receiveCompletion: { _ in }) { (result) in
            guard let result = result else { XCTFail(); return }
            self.ms.findSecurity(for: result).sink(receiveCompletion: { error in
                print("Error: \(error)")
                expect.fulfill()
            }) { (security) in
                print(security)
                XCTAssert(security?.secId == "FOUSA00L8W", "Incorrect fund id")
            }.store(in: &self.requests)
        }.store(in: &requests)
        
        waitForExpectations(timeout: 10, handler: nil)
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
