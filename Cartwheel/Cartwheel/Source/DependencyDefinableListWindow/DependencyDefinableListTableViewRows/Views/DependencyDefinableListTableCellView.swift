//
//  DependencyDefinableListTableCellView.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 8/22/15.
//  Copyright (c) 2015 Saturday Apps. All rights reserved.
//

import Cocoa

// this is the cell the tableview deques
// its only job is to load my custom controller
// which will then fill it with subviews

final class DependencyDefinableListTableCellView: NSTableCellView {    
    static let identifier = "DependencyDefinableListTableCellView"
    override var identifier: String? {
        get { return self.classForCoder.identifier }
        set { /* do nothing */ /* this setter is needed to please the compiler */ }
    }
}