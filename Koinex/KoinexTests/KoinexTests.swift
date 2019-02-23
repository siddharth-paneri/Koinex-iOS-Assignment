//
//  KoinexTests.swift
//  KoinexTests
//
//  Created by Siddharth Paneri on 22/02/19.
//  Copyright © 2019 Koinex. All rights reserved.
//

import XCTest
@testable import Koinex

class KoinexTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testKoinParsing() {
        let dataToParse: [String: Any] = [
            "prices":["inr":["ETH":"10630"], "true_usd":[ "XRP": "0.3164"]],"stats":["inr":["ETH": ["highest_bid":"10453.06","lowest_ask": "10627","last_traded_price": "10630","min_24hrs": "10365.04","max_24hrs": "10699.93","vol_24hrs": "63.592","currency_full_form": "ether","currency_short_form": "ETH","baseCurrency": "inr","per_change": "0.3777148253068933","trade_volume": "382273.64472999994"]],"true_usd": ["XRP": ["highest_bid": "0.3164","lowest_ask": "0.3201","last_traded_price": "0.3164","min_24hrs": "0.3097","max_24hrs": "0.3207","vol_24hrs": "3575.0","currency_full_form": "ripple","currency_short_form": "XRP","baseCurrency": "true_usd","per_change": "-0.690521029504074","trade_volume": "1133.923300000001"]]]]
        
        let parsed = KoinParser.parse(dic: dataToParse)
        if parsed.count == 2 {
            // pass
        } else {
            XCTFail("Parsing error")
        }
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
