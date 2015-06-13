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
    var isLastCell = false {
        didSet {
            self.ui.separatorView.hidden = self.isLastCell
        }
    }
    
    func viewDidLoad() {
        self.wantsLayer = true
        
        self.ui.allViews().map { self.addSubview($0) }
        self.configure(cartfileTitleLabel: self.ui.cartfileTitleLabel)
        self.configure(separatorView: self.ui.separatorView)
        self.configureLayoutConstraints()
    }
    
    private func configureLayoutConstraints() {
        let defaultInset = CGFloat(8.0)
        let smallInset = round(defaultInset / 1.5)
        
        let pureLayoutConstraints = NSView.autoCreateConstraintsWithoutInstalling() {
            self.ui.cartfileTitleLabel.autoPinEdgeToSuperviewEdge(ALEdge.Leading, withInset: defaultInset)
            self.ui.cartfileTitleLabel.autoAlignAxis(ALAxis.Horizontal, toSameAxisOfView: self, withOffset: -2)
            
            self.ui.separatorView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 0)
            self.ui.separatorView.autoPinEdgeToSuperviewEdge(.Leading, withInset: defaultInset * 2)
            self.ui.separatorView.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 0)
            self.ui.separatorView.autoSetDimension(.Height, toSize: 1)
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
            cartfileTitleLabel.font = NSFont.systemFontOfSize(NSFont.systemFontSize())
        } else {
            fatalError("CartListTableCellView: Tried to configure test label before it was in the view hierarchy.")
        }
    }
    
    private func configure(#separatorView: NSVisualEffectView) {
        if let _ = separatorView.superview {
            separatorView.material = .Dark
        } else {
            fatalError("CartListTableCellView: Tried to configure separatorView before it was in the view hierarchy.")
        }
    }
    
    func clearCellView() {
        self.layer?.backgroundColor = NSColor.clearColor().CGColor
        self.ui.cartfileTitleLabel.stringValue = ""
    }
    
    func cellWasDeselected() {
        println("\(self) was de-selected")
        self.layer?.backgroundColor = NSColor.clearColor().CGColor
    }
    
    func cellWasSelected() {
        println("\(self) was selected")
        self.layer?.backgroundColor = NSColor.blueColor().CGColor
    }
    
    func cellWasHighlighted() {
        println("\(self) was highlighted")
        self.layer?.backgroundColor = NSColor.redColor().CGColor
    }
    
    struct interfaceView {
        var cartfileTitleLabel = NSTextField()
        var separatorView = NSVisualEffectView()
        
        func allViews() -> [NSView] {
            return [cartfileTitleLabel, separatorView]
        }
    }
}

extension CartListTableCellView: Printable {
    override var description: String {
        return "CartListTableCellView \(self.ui.cartfileTitleLabel.stringValue):"
    }
}
