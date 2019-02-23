//
//  KoinListViewModel.swift
//  Koinex
//
//  Created by Siddharth Paneri on 22/02/19.
//  Copyright © 2019 Koinex. All rights reserved.
//

import Foundation

class KoinListViewModel {
    
    private var allKoinViewModels: [KoinViewModel] = []
    private var currencySpecificKoinViewModels: [KoinViewModel] = []
    private let dataProvider = DataProvider()
    var supportedCurrencies: [Currency] = [Currency.inr, Currency.tusd]
    
    var didUpdate: (()->())? = nil
    var didFail: ((KoinError?)->())? = nil
    var currency: Currency = .inr {
        didSet {
            // filter the view models
            if currency != oldValue {
                updateKoinsForCurrency()
                self.didUpdate?()
            }
        }
    }
    
    var count: Int {
        return currencySpecificKoinViewModels.count
    }
    
    init() {
        Polling.sharedInstance.didPoll = {
            self.fetchKoins()
        }
        Polling.sharedInstance.shouldAutoStartPolling = true
        Polling.sharedInstance.startPolling()
    }
    
    deinit {
        Polling.sharedInstance.didPoll = nil
        Polling.sharedInstance.shouldAutoStartPolling = false
        Polling.sharedInstance.stopPolling()
    }
    
    func koinViewModel(at index: Int) -> KoinViewModel? {
        if count > 0 && index >= 0 && index < count {
            return currencySpecificKoinViewModels[index]
        }
        return nil
    }
    
    func koinViewModel(with shortName: String) -> KoinViewModel? {
        let filtered = currencySpecificKoinViewModels.filter{$0.shortName.lowercased() == shortName.lowercased() }
        if filtered.count > 0 {
            return filtered[0]
        }
        return nil
    }
    
    
    private func updateKoinsForCurrency() {
        currencySpecificKoinViewModels = allKoinViewModels.filter{ $0.currency == currency }
    }
    
    func fetchKoins() {
        print(#function)
        // reset polling before we fetch the data from API
//        Polling.sharedInstance.stopPolling()
        // fetch the data from data provider
        dataProvider.fetchKoinData { [weak self] (koinModels, error) in
            guard let strongSelf = self else {
                return
            }
            
            if let err = error {
                print("Error received")
                // remove all data from view models
                strongSelf.allKoinViewModels.removeAll()
                strongSelf.currencySpecificKoinViewModels.removeAll()
                // call did fail closure
                strongSelf.didFail?(err)
                return
            }
            
            guard let models = koinModels else {
                print("Response received")
                // remove all data from view models
                strongSelf.allKoinViewModels.removeAll()
                strongSelf.currencySpecificKoinViewModels.removeAll()
                // call did fail closure with empty response error
                strongSelf.didFail?(KoinError.emptyResponse)
                return
            }
            // assign KoinListViewModels new data
            var kvms: [KoinViewModel] = []
            for koinModel in models {
                let kvm = KoinViewModel(with: koinModel)
                kvms.append(kvm)
            }
            // update view models
            print("Response received")
            strongSelf.allKoinViewModels = kvms
            strongSelf.updateKoinsForCurrency()
            strongSelf.didUpdate?()
        }
    }
}
