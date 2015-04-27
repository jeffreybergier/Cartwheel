//
// CartListViewController.swift
// Cartwheel
//
// Created by Jeffrey Bergier on 4/12/15.
// Copyright (c) 2015 Saturday Apps. All rights reserved.
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Jeffrey Bergier
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Cocoa

class CartListViewController: NSViewController {
    
    weak var window: NSWindow!
    
    private var constraints: [NSLayoutConstraint]?
    private let contentView = NSView()
    
    override func loadView() {
        self.view = NSView()
        
        self.contentView.wantsLayer = true
        self.contentView.layer?.backgroundColor = NSColor.blueColor().CGColor
        self.contentView.frame = NSRect(x: 10, y: 10, width: 30, height: 30)
        self.view.addSubview(self.contentView)
        self.contentView.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsetsZero)
        
        let toolbar = CLToolbar(identifier: "PreferencesToolbar")
        toolbar.insertItemWithItemIdentifier("something", atIndex: 0)
        self.window.toolbar = toolbar
    }
    
}

class CLToolbar: NSToolbar {
    override func insertItemWithItemIdentifier(itemIdentifier: String, atIndex index: Int) {
        super.insertItemWithItemIdentifier(itemIdentifier, atIndex: index)
    }
}
