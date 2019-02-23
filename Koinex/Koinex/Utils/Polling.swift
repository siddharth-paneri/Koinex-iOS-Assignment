//
//  Polling.swift
//  Koinex
//
//  Created by Siddharth Paneri on 22/02/19.
//  Copyright © 2019 Koinex. All rights reserved.
//

import Foundation


class Polling {
    
    private static var _sharedInstance: Polling? = nil
    private var _pollingTimer: Timer? = nil
    class var sharedInstance: Polling {
        guard let shared = _sharedInstance else {
            _sharedInstance = Polling()
            return _sharedInstance!
        }
        return shared
    }
    
    // to subscribe for poll
    var didPoll: (()->())? = nil
    var isPolling: Bool = false
    var shouldAutoStartPolling: Bool = false
    
    // max number of polling
    fileprivate var _polls : Int = 0
    
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: NSNotification.Name(rawValue: NOTIF_APP_ACTIVE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appResiginActive), name: NSNotification.Name(rawValue: NOTIF_APP_INACTIVE), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIF_APP_ACTIVE), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIF_APP_INACTIVE), object: nil)
    }
    
    func destroy() {
        reset()
    }
    
    /** DispatchSourceTimer for polling on global queue */
    private var _gcdTimer : DispatchSourceTimer?
    
    private func fetchNewTimer() -> DispatchSourceTimer {
        let gcdTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        
        gcdTimer.setEventHandler(handler: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.poll()
            
        })
        gcdTimer.setCancelHandler(handler: {
            print("timer cancled")
        })
        gcdTimer.schedule(deadline: .now()+PollingTimeInterval, repeating: PollingTimeInterval)
        return gcdTimer
    }
    
    /** schedules task */
    @objc private func poll(){
        print("Poll - \(_polls) at \(Date())");
        _polls += 1
        if _polls == PollingMaxCount {
            self.reset()
        }
        self.didPoll?()
    }

    /** reset timer */
    private func reset() {
        _gcdTimer?.setEventHandler(handler: nil)
        _gcdTimer?.cancel()
        _gcdTimer = nil
        _polls = 0
        isPolling = false
    }
    
    /**  start polling*/
    func startPolling() {
        print(#function)
        if _gcdTimer == nil {
            _gcdTimer = fetchNewTimer()
        }
        _gcdTimer?.resume()
        isPolling = true
    }
    
    /** stop polling */
    func stopPolling() {
        print(#function)
        self.reset()
    }
    
    
    /** Notification observer for when application becomes active */
    @objc private func appDidBecomeActive() {
        print(#function)
        if self.shouldAutoStartPolling {
            if !self.isPolling {
                self.startPolling()
            }
        }

    }
    
    /** Notification observer for when application becomes in-active */
    @objc private func appResiginActive() {
        print(#function)
        if isPolling {
            stopPolling()
        }
    }
    
    
}
