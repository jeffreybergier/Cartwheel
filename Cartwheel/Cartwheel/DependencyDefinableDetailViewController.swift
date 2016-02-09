//
//  DependencyDefinableDetailViewController.swift
//  Cartwheel
//
//  Created by aGitated crAnberries on 2/8/16.
//  Copyright © 2016 Saturday Apps. All rights reserved.
//

import Cocoa

class DependencyDefinableDetailViewController: NSViewController {
    
    var content: DependencyDefinable? {
        didSet {
            print("\(self.content?.title)")
        }
    }
    
}