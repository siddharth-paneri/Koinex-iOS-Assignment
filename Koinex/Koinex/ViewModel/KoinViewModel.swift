//
//  KoinViewModel.swift
//  Koinex
//
//  Created by Siddharth Paneri on 22/02/19.
//  Copyright © 2019 Koinex. All rights reserved.
//

import Foundation
import  UIKit


class KoinViewModel {
    
    private var koinModel: KoinModel!
    
    init(with model: KoinModel) {
        koinModel = model
    }
    
    var name: String {
        return koinModel.fullName.uppercased()
    }
    
    var shortName: String {
        return koinModel.shortName.uppercased()
    }
    
    var highestBid: Double {
        return koinModel.highestBid
    }
    
    var lowestAsk: Double {
        return koinModel.lowestAsk
    }
    
    var price: Double {
        return koinModel.lastTradePrice
    }
    var formattedPrice: String {
        return currency.symbol + price.value()
    }
    
    var minimumOf24Hr: Double {
        return koinModel.minOf24Hr
    }
    
    var maximumOf24Hr: Double {
        return koinModel.maxOf24Hr
    }
    
    var volumeOf24Hr: Double {
        return koinModel.volOf24Hr
    }
    
    var currency: Currency {
        return koinModel.currency
    }
    
    var currencyValue: String {
        switch koinModel.currency {
        case .inr:
            return "INR"
        case .tusd:
            return "TUSD"
        default:
            return ""
        }
    }
    
    var percentageChange: Double {
        return koinModel.perChange
    }
    
    var formattedPercentageChange: String {
        var prefix = ""
        if percentageChange > 0 {
            prefix = "+"
        }
        return prefix + percentageChange.format(f: ".2") + "%"
    }
    
    var color: UIColor {
        if percentageChange > 0 {
          return UIColor(hexString: Theme.Color.green.rawValue)
        } else if percentageChange < 0 {
          return UIColor(hexString: Theme.Color.red.rawValue)
        }
        return .white
    }
    
    var tradeVolume: Double {
        return koinModel.tradeVolume
    }
    
    
    var supportedStats: [Stats] = [.highestBid, .lowestAsk, .minimumOf24Hr, .maximumOf24Hr, .volumeOf24Hr, .tradeVolume]
    
    
    func valueFor(stat: Stats) -> String {
        switch stat {
        case .highestBid:
            return currency.symbol + highestBid.value()
        case .lowestAsk:
            return currency.symbol + lowestAsk.value()
        case .minimumOf24Hr:
            return currency.symbol + minimumOf24Hr.value()
        case .maximumOf24Hr:
            return currency.symbol + maximumOf24Hr.value()
        case .volumeOf24Hr:
            return volumeOf24Hr.value()
        case .tradeVolume:
            return tradeVolume.value()
        }
    }
    
}
