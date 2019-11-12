//
//  PortfolioTests.swift
//  portfolio-xray-macosTests
//
//  Created by Konstantin Klitenik on 10/27/19.
//  Copyright © 2019 KK. All rights reserved.
//

import XCTest
import Combine
@testable import portfolio_xray_macos

class PortfolioTests: XCTestCase {
    let portfolio = Portfolio(persist: false)
    
    var subs: Set<AnyCancellable> = []

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddFund() {
        let exp1 = self.expectation(description: "Add fund")
        
        var pubCount = 0
        
        portfolio.$funds.sink { funds in
            pubCount += 1
            print("Pub count \(pubCount): \(funds.count)")
            if pubCount == 2 {
                XCTAssert(funds.count == 1)
            } else if pubCount == 3 {
                exp1.fulfill()
                XCTAssert(funds.count == 3)
            }
        }.store(in: &subs)
        
        portfolio.addFund(ticker: "VFIAX")
//        portfolio.addFunds(tickers: ["VSMAX", "VSIAX"])
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssert(pubCount == 3)
    }
}
