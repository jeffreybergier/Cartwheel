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

class CartfileUpdaterController: CartfileUpdateControllerDelegate {
    
    private var updatesInProgress = [CWCartfile : CartfileUpdater]()
    
    func updateCartfile(cartfile: CWCartfile, forceRestart force: Bool = false) {
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
        self.updateObserver.notify(cartfile)
    }
    
    func cancelUpdateForCartfile(cartfile: CWCartfile) -> Bool {
        if let update = self.updatesInProgress[cartfile] {
            update.cancel()
            self.updatesInProgress.removeValueForKey(cartfile)
            self.updateObserver.notify(cartfile)
            return true
        }
        self.updateObserver.notify(cartfile)
        return false
    }
    
    func statusForCartfile(cartfile: CWCartfile) -> CartfileUpdater.Status {
        if let update = self.updatesInProgress[cartfile] {
            return update.status
        }
        return .NonExistant
    }
    
    let updateObserver = ObserverSet<CWCartfile>()
    func cartfile(cartfile: CWCartfile, statusChanged status: CartfileUpdater.Status) {
        self.updateObserver.notify(cartfile)
    }

}