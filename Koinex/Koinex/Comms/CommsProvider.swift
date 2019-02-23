//
//  CommsProvider.swift
//  Koinex
//
//  Created by Siddharth Paneri on 22/02/19.
//  Copyright © 2019 Koinex. All rights reserved.
//

import Foundation

class CommsProvider: NSObject {
    
    private static var _sharedInstance: CommsProvider? = nil
    
    fileprivate var sharedSession: URLSession? = nil
    
    class var sharedInstance: CommsProvider {
        guard let shared = _sharedInstance else {
            _sharedInstance = CommsProvider()
            return _sharedInstance!
        }
        return shared
    }
    
    override init() {
        let configuration = URLSessionConfiguration.default
        sharedSession = URLSession(configuration: configuration)
    }
    
    
    /** fetch data from API and return json/error */
    func request(type: RequestType, params: [String: Any]?, _ completionHandler: @escaping (Any?, KoinError?)->()) {
        
        guard let session = sharedSession else {
            return
        }
        
        var query = ""
        switch type {
        case .ticker:
            query = "/ticker"
            
        }
        
        guard let url = URL(string: API_BASE_URL + query) else {
            return
        }
        
        let task = session.dataTask(with: url) { (data, response, error) in

            if error != nil {
                completionHandler(nil, .networkError)
                return
            }

            guard let responseData = data else {
                completionHandler(nil, nil)
                return
            }
            
            do {
                let jsonObj = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                completionHandler(jsonObj, nil)
                return
            } catch {
                //parsing error
                completionHandler(nil, .parsingError)
                return
            }
            
        }
        
        task.resume()
        
    }
    
    
}

extension CommsProvider: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print(challenge.debugDescription)
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print(error.debugDescription)
    }
    
    
}
