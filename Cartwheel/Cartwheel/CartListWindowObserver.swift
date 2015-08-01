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

protocol TableViewRowIsDraggingObserver {
    var tableViewRowIsDraggingObserver: ObserverSet<Bool> { get }
}

protocol WindowDidChangeFrameObserver {
    var windowDidChangeFrameObserver: ObserverSet<NSRect?> { get }
}

protocol WindowDidCloseObserver {
    var windowDidCloseObserver: ObserverSet<Void> { get }
}

class CartListWindowObserver:
    WindowMainStateObserver,
    TableViewRowSelectedStateObserver,
    TableViewRowIsDraggingObserver,
    WindowDidChangeFrameObserver,
    WindowDidCloseObserver
    
{
    
    init(windowToObserve: NSWindow?) {
        if let window = windowToObserve {
            // register for notifications
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowDidBecomeMain:", name: NSWindowDidBecomeMainNotification, object: window)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowDidResignMain:", name: NSWindowDidResignMainNotification, object: window)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowDidChangeFrame:", name: NSWindowDidEndLiveResizeNotification, object: window)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowDidChangeFrame:", name: NSWindowDidMoveNotification, object: window)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowDidClose:", name: NSWindowWillCloseNotification, object: window)
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
    
    // MARK: TableViewRowIsDraggingObserver Protocol
    
    let tableViewRowIsDraggingObserver = ObserverSet<Bool>()
    
    // MARK: WindowDidChangeSizeObserver Protocol
    
    let windowDidChangeFrameObserver = ObserverSet<NSRect?>()
    
    @objc private func windowDidChangeFrame(notification: NSNotification) {
        let frame = (notification.object as? NSWindow)?.frame
        self.windowDidChangeFrameObserver.notify(frame)
    }
    
    // MARK: WindowDidCloseObserver
    
    var windowDidCloseObserver = ObserverSet<Void>()
    
    @objc private func windowDidClose(notification: NSNotification) {
        self.windowDidCloseObserver.notify()
    }
    
    // MARK: Handle Going Away
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
