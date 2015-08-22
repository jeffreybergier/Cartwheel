//
//  CartfileUpdaterController.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 8/16/15.
//
//  Copyright (c) 2015 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF COwNTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import ReactiveCocoa
import ObserverSet

class CartfileUpdaterManager: CartfileUpdaterDelegate {
    
    let changeNotifier = ObserverSet<Cartfile>()
    private var updatesInProgress = [Cartfile : CartfileUpdater]()
    
    func updateCartfile(cartfile: Cartfile, forceRestart force: Bool = false) {
        switch self.statusForCartfile(cartfile) {
        case .NonExistant:
            let updater = CartfileUpdater(cartfile: cartfile, delegate: self)
            updater.start()
            self.updatesInProgress[cartfile] = updater
        case .NotStarted:
            self.updatesInProgress[cartfile]?.start()
        case .InProgressIndeterminate, .InProgressDeterminate(let _), .FinishedSuccess:
            if force == true {
                self.cancelUpdateForCartfile(cartfile)
                let updater = CartfileUpdater(cartfile: cartfile, delegate: self)
                updater.start()
                self.updatesInProgress[cartfile] = updater
            }
        case .FinishedInterrupted, .FinishedError(let _):
            self.cancelUpdateForCartfile(cartfile)
            let updater = CartfileUpdater(cartfile: cartfile, delegate: self)
            updater.start()
            self.updatesInProgress[cartfile] = updater
        }
        self.changeNotifier.notify(cartfile)
    }
    
    func cancelUpdateForCartfile(cartfile: Cartfile) -> Bool {
        if let update = self.updatesInProgress[cartfile] {
            update.cancel()
            self.updatesInProgress.removeValueForKey(cartfile)
            self.changeNotifier.notify(cartfile)
            return true
        }
        self.changeNotifier.notify(cartfile)
        return false
    }
    
    func statusForCartfile(cartfile: Cartfile) -> CartfileUpdater.Status {
        if let update = self.updatesInProgress[cartfile] {
            return update.status
        }
        return .NonExistant
    }
}