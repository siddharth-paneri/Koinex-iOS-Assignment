//
//  DataProvider.swift
//  Koinex
//
//  Created by Siddharth Paneri on 22/02/19.
//  Copyright © 2019 Koinex. All rights reserved.
//

import Foundation

class DataProvider {

    /** fetch koin data from API and return Koin model*/
    func fetchKoinData(_ completionHandler: @escaping ([KoinModel]?, KoinError?)->()) {
        CommsProvider.sharedInstance.request(type: .ticker, params: nil) { (response, error) in
            if let koinError = error {
                completionHandler(nil, koinError)
                return
            }
            
            guard let jsonObject = response as? [String: Any] else {
                completionHandler(nil, .emptyResponse)
                return
            }
            
            let koins = KoinParser.parse(dic: jsonObject)
            if koins.count > 0 {
                completionHandler(koins, nil)
            } else {
                completionHandler(nil, .emptyResponse)
            }
        }
    }
    
}
