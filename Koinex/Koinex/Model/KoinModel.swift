//
//  KoinModel.swift
//  Koinex
//
//  Created by Siddharth Paneri on 22/02/19.
//  Copyright © 2019 Koinex. All rights reserved.
//

import Foundation

struct KoinModel {
    let highestBid: Double
    let lowestAsk: Double
    let lastTradePrice: Double
    let minOf24Hr: Double
    let maxOf24Hr: Double
    let volOf24Hr: Double
    let fullName: String
    let shortName: String
    let currency: Currency
    let perChange: Double
    let tradeVolume: Double
}

class KoinParser {
    
    /** Parse JSON object to Koin model */
    class func parse(_ koin: [String: Any]) -> KoinModel {
        var highestBid: Double = 0.0
        var lowestAsk: Double = 0.0
        var lastTradePrice: Double = 0.0
        var minOf24Hr: Double = 0.0
        var maxOf24Hr: Double = 0.0
        var volOf24Hr: Double = 0.0
        var fullName: String = ""
        var shortName: String = ""
        var currency: Currency = .none
        var perChange: Double = 0.0
        var tradeVolume: Double = 0.0
        
        if let highBid = koin["highest_bid"] as? String {
            if let value = Double(highBid) {
                highestBid = value
            }
        }
        if let lowAsk = koin["lowest_ask"] as? String {
            if let value = Double(lowAsk) {
                lowestAsk = value
            }
        }
        if let price = koin["last_traded_price"] as? String {
            if let value = Double(price) {
                lastTradePrice = value
            }
        }
        if let min = koin["min_24hrs"] as? String {
            if let value = Double(min) {
                minOf24Hr = value
            }
        }
        if let max = koin["max_24hrs"] as? String {
            if let value = Double(max) {
                maxOf24Hr = value
            }
        }
        if let vol = koin["vol_24hrs"] as? String {
            if let value = Double(vol) {
                volOf24Hr = value
            }
        }
        if let name = koin["currency_full_form"] as? String {
            fullName = name
        }
        if let short = koin["currency_short_form"] as? String {
            shortName = short
        }
        if let curr = koin["baseCurrency"] as? String {
            if let value = Currency(rawValue: curr) {
                currency = value
            }
        }
        if let change = koin["per_change"] as? String {
            if let value = Double(change) {
                perChange = value
            }
        }
        if let vol = koin["trade_volume"] as? String {
            if let value = Double(vol) {
                tradeVolume = value
            }
        }
        
        return KoinModel(highestBid: highestBid, lowestAsk: lowestAsk, lastTradePrice: lastTradePrice, minOf24Hr: minOf24Hr, maxOf24Hr: maxOf24Hr, volOf24Hr: volOf24Hr, fullName: fullName, shortName: shortName, currency: currency, perChange: perChange, tradeVolume: tradeVolume)
    }
    
    
    class func parse(dic: [String: Any]) -> [KoinModel] {
        guard let stats = dic["stats"] as? [String: Any] else {
            return []
        }
        var koinModels: [KoinModel] = []
        for currencyKoins in stats.values {
            if let koinStats = currencyKoins as? [String: Any] {
                for koinStat in koinStats.values {
                    if let stat = koinStat as? [String: Any] {
                        koinModels.append(KoinParser.parse(stat))
                    }
                }
            }
        }
        return koinModels
    }
    
}

