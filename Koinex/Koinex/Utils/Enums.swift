//
//  Enums.swift
//  Koinex
//
//  Created by Siddharth Paneri on 22/02/19.
//  Copyright © 2019 Koinex. All rights reserved.
//

import Foundation
import UIKit

enum RequestType: Int {
    case ticker = 1
}

enum Currency: String {
    case none = ""
    case inr = "inr"
    case tusd = "true_usd"
    
    var value: String {
        switch self {
        case .none:
            return ""
        case .inr:
            return "INR"
        case .tusd:
            return "TUSD"
        }
    }
    
    var symbol: String {
        switch self {
        case .none:
            return ""
        case .inr:
            return "₹"
        case .tusd:
            return "$"
        }
    }
}

enum KoinError: Error
{
    case networkError
    case parsingError
    case emptyResponse
    
    
    var tupple: (title: String, message: String?) {
        switch self {
        case .networkError:
            return ("Error", "Network error")
        case .parsingError:
            return ("Error", "Internal error, contact technical support")
        case .emptyResponse:
            return ("No data available", nil)
        }
    }
}


enum Theme {
    enum Color: String {
        case red = "#CD5C5C"//#B22222"//"#DC143C"
        case green = "#198A51"
        case backgroundBlue = "#1B3247"
    }
    
    enum FontSize: CGFloat {
        case small = 12.0
        case medium = 14.0
        case large = 18.0
        case xLarge = 22.0
        case xxLarge = 24.0
    }
}


enum Stats: Int {
    
    case highestBid = 1
    case lowestAsk = 2
    case minimumOf24Hr = 4
    case maximumOf24Hr = 5
    case volumeOf24Hr = 6
    case tradeVolume = 7
    
    var value: String {
        switch self {
        case .highestBid:
            return "Highest bid"
        case .lowestAsk:
            return "Lowest ask"
        case .minimumOf24Hr:
            return "Minimum of 24hr"
        case .maximumOf24Hr:
            return "Maximum of 24hr"
        case .volumeOf24Hr:
            return "Volume of 24hr"
        case .tradeVolume:
            return "Trade volume"
        }
    }
    
}
