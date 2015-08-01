//
//  CartListWindowObserver.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 7/31/15.
//  Copyright (c) 2015 Saturday Apps. All rights reserved.
//

import Cocoa
import ObserverSet

protocol WindowMainStateObserver {
    var windowMainStateObserver: ObserverSet<Bool> { get }
}

protocol TableViewRowSelectedStateObserver {
    var tableViewRowSelectedStateObserver: ObserverSet<[Range<Int>]> { get }
}

protocol TableViewIsDraggingObserver {
    var tableViewIsDraggingObserver: ObserverSet<Bool> { get }
}

class CartListWindowObserver: WindowMainStateObserver, TableViewRowSelectedStateObserver {

    init(windowToObserve: NSWindow?) {
        if let window = windowToObserve {
            // register for notifications
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowDidBecomeMain:", name: NSWindowDidBecomeMainNotification, object: window)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowDidResignMain:", name: NSWindowDidResignMainNotification, object: window)
        }
    }
    
    // MARK: WindowMainObserver Protocol
    
    var windowMainStateObserver = ObserverSet<Bool>()
    
    @objc private func windowDidBecomeMain(notification: NSNotification) {
        self.windowMainStateObserver.notify(true)
    }
    @objc private func windowDidResignMain(notification: NSNotification) {
        self.windowMainStateObserver.notify(false)
    }
    
    // MARK: TableViewRowSelectedStateObserver Protocol

    let tableViewRowSelectedStateObserver = ObserverSet<[Range<Int>]>()
    
    // MARK: TableViewIsDraggingObserver Protocol
    
    let tableViewIsDraggingObserver = ObserverSet<Bool>()
}
