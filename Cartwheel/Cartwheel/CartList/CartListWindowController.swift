//
//  CartListWindowController.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 4/28/15.
//  Copyright (c) 2015 Saturday Apps. All rights reserved.
//

import Cocoa

class CartListWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        self.window!.collectionBehavior = NSWindowCollectionBehavior.FullScreenPrimary
    }
}
