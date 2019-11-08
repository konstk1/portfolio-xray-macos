//
//  MorningStarTests.swift
//  portfolio-xray-macosTests
//
//  Created by Konstantin Klitenik on 10/26/19.
//  Copyright © 2019 KK. All rights reserved.
//

import XCTest
import Combine
@testable import portfolio_xray_macos

class MorningStartTests: XCTestCase {
    let ms = MorningStar()
    
    let entity = MorningStar.Entity(id: "us_security_tmp-XNAS_VFIAX", exchange: "XNAS", securityType: "FO", ticker: "VFIAX", name: "VFIAX", performanceId: "0P00002YHQ")
    let security = MorningStar.Security(name: "VFIAX", exchange: "XNAS", performanceId: "0P00002YHQ", secId: "FOUSA00L8W", ticker: "VFIAX", type: "FO")

    
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
        ms.findEntity(ticker: entity.ticker).sink(receiveCompletion: { error in
            guard case .finished = error else {
                print("Error: \(error)")
                XCTFail(); return
            }
            expect.fulfill()
        }) { (result) in
            print(result)
            XCTAssert(result.ticker == self.entity.ticker, "Ticker doesn't match")
            XCTAssert(result.exchange == self.entity.exchange, "Incorrect exchange info")
            XCTAssert(result.securityType == self.entity.securityType, "Incorrect security type")
        }.store(in: &requests)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testFindSecurity() {
        let expect = self.expectation(description: "Find sec")
        
        self.ms.findSecurity(for: entity).sink(receiveCompletion: { error in
            guard case .finished = error else {
                print("Error: \(error)")
                XCTFail(); return
            }
            expect.fulfill()
        }) { (security) in
            print(security)
            XCTAssert(security.secId == security.secId, "Incorrect fund id")
        }.store(in: &requests)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testAssetAlloc() {
        let expect = self.expectation(description: "Asset alloc")
        
        ms.getAllocation(for: "VFIAX").sink(receiveCompletion: { error in
            guard case .finished = error else {
                print("Error: \(error)")
                XCTFail(); return
            }
            expect.fulfill()
        }) { alloc in
            print(alloc)
        }.store(in: &requests)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testMarketCap() {
        let expect = self.expectation(description: "Asset alloc")
        
        ms.getCapAllocation(for: security).sink(receiveCompletion: { error in
            expect.fulfill()
            guard case .finished = error else {
                print("Error: \(error)")
                XCTFail(); return
            }
        }) { capAlloc in
            print(capAlloc)
            XCTAssert(capAlloc.giant > 50.0)
            XCTAssert(capAlloc.small < 1.0)
        }.store(in: &requests)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testRegions() {
        let expect = self.expectation(description: "Regions alloc")
        
        ms.getRegionAlloc(for: security).sink(receiveCompletion: { error in
            expect.fulfill()
            guard case .finished = error else {
                print("Error: \(error)")
                XCTFail(); return
            }
        }) { regions in
            print(regions)
            XCTAssert(regions.northAmerica > 95.0)
            XCTAssert(regions.africaMiddleEast < 1.0)
        }.store(in: &requests)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
