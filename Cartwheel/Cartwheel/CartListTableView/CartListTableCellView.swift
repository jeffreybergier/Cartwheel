//
//  CartListTableCellView.swift
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

class CartListTableCellView: NSView {
    
    let ui = interfaceView()
    var viewConstraints = [NSLayoutConstraint]()
    
    func viewDidLoad() {
        self.wantsLayer = true
        
        self.addSubview(self.ui.cartfileTitleLabel)
        self.configure(cartfileTitleLabel: self.ui.cartfileTitleLabel)
        self.configureLayoutConstraints()
    }
    
    private func configureLayoutConstraints() {
        let pureLayoutConstraints = NSView.autoCreateConstraintsWithoutInstalling() {
            self.ui.cartfileTitleLabel.autoPinEdgeToSuperviewEdge(ALEdge.Leading)
            self.ui.cartfileTitleLabel.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
        }
        
        let optionalPureLayoutConstraints = pureLayoutConstraints.map { (object) -> NSLayoutConstraint? in
            if let constraint = object as? NSLayoutConstraint {
                return constraint
            } else {
                return nil
            }
        }
        
        self.viewConstraints += Array.filterOptionals(optionalPureLayoutConstraints)
        self.addConstraints(self.viewConstraints)
    }
    
    private func configure(#cartfileTitleLabel: NSTextField) {
        if let _ = cartfileTitleLabel.superview {
            cartfileTitleLabel.bordered = false
            (cartfileTitleLabel.cell() as? NSTextFieldCell)?.drawsBackground = false
            cartfileTitleLabel.editable = false
        } else {
            fatalError("CartListTableCellView: Tried to configure test label before it was in the view hierarchy.")
        }
    }
    
    struct interfaceView {
        var cartfileTitleLabel = NSTextField()
    }
    
}
