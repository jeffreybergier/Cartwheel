//
//  CartListTableCellViewController.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 4/28/15.
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
//

import Cocoa
import PureLayout_Mac
import XCGLogger

final class PodfileTableCellViewController: NSObject {
    
    weak var view: NSTableCellView!
    
    var podfile: Podfile! {
        didSet {
            self.prepareCellForNewModelObject()
            self.updateCellWithNewModelObject()
        }
    }
    
    private let log = XCGLogger.defaultInstance()
    private weak var parentWindow: NSWindow!
    
    private let defaultView = DefaultCartfileTableCellView()
    
    private func prepareCellForNewModelObject() {
        self.defaultView.clearCellContents()
    }
    
    private func updateCellWithNewModelObject() {
        if let cartfile = self.podfile {
            self.defaultView.setPrimaryTextFieldString(cartfile.name)
        } else {
            self.defaultView.clearCellContents()
        }
    }
    
    private var configured = false
    func configureViewWithWindow(window: NSWindow) {
        if self.configured == false {
            // set the window
            self.parentWindow = window
            
            // add the views
            self.view.addSubview(self.defaultView)
            
            // configure the constraints
            self.configureConstraints()
            
            // configure the views
            self.defaultView.viewDidLoad()
            
            // configure the button
            self.defaultView.setPrimaryButtonTitle(NSLocalizedString("Update", comment: "Button to perform carthage update"))
            self.defaultView.setPrimaryButtonAction("didClickUpdateCartfileButton:", forTarget: self)
            
            // done configuring, don't do it again when cell is recycled
            self.configured = true
        }
    }
    
    private var normalLayoutConstraints = [NSLayoutConstraint]()
    
    private func configureConstraints() {
        let defaultInset = CGFloat(8.0)
        let smallInset = round(defaultInset / 1.5)
        
        self.normalLayoutConstraints = NSView.autoCreateConstraintsWithoutInstalling() {
            self.defaultView.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsetsZero)

            }.filter() { object -> Bool in
                if let contraint = object as? NSLayoutConstraint { return true } else { return false }
            }.map() { object -> NSLayoutConstraint in
                return object as! NSLayoutConstraint
        }
        
        self.view.addConstraints(self.normalLayoutConstraints)
    }
    
    @objc private func didClickUpdateCartfileButton(sender: NSButton) {

    }
    
    @objc private func didClickShowUpdateWarningsButton(sender: NSButton) {
        
    }
    
    // MARK: Special Property used to Calculate Row Height
    
    var viewHeightForTableRowHeightCalculation: CGFloat {
        return self.defaultView.viewHeightForTableRowHeightCalculation
    }
}
