//
//  CWDefaultsPlist.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 6/2/15.
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

import Foundation

struct CWDefaultsPlist {
    var cartfileDirectorySearchRecursion: Int
    var cartfileListSaveLocation: String
    
    init() {
        // declare the needed values
        let cartfileDirectorySearchRecursion: NSNumber?
        let cartfileListSaveLocation: String?
        
        // read the plist from disk
        var dataError: NSError?
        var plistError: NSError?
        if let plistURL = NSBundle.mainBundle().URLForResource("CartwheelDefaults", withExtension: "plist"),
            let data = NSData(contentsOfURL: plistURL, options: nil, error: &dataError),
            let plist = NSPropertyListSerialization.propertyListWithData(data, options: NSPropertyListReadOptions.allZeros, format: nil, error: &plistError) as? NSDictionary {
                
                // parse the plist
                cartfileDirectorySearchRecursion = plist["CartfileDirectorySearchRecursion"] as? NSNumber
                cartfileListSaveLocation = plist["CartfileListSaveLocation"] as? String
        } else {
            // handle errors
            cartfileDirectorySearchRecursion = nil
            cartfileListSaveLocation = nil
            NSLog("CWDefaultsPlist: Error Reading Plist from Disk. Using Defaults. PlistError: \(plistError) – DataError: \(dataError)")
        }
        
        // populate properties with values
        self.cartfileDirectorySearchRecursion = cartfileDirectorySearchRecursion?.integerValue ?? 4
        self.cartfileListSaveLocation = cartfileListSaveLocation ?? "cartfiles.bin"
    }
}

extension CWDefaultsPlist: Printable {
    var description: String {
        return "CWDefaultsPlist: cartfileDirectorySearchRecursion: \(self.cartfileDirectorySearchRecursion) – cartfileListSaveLocation: \(self.cartfileListSaveLocation)"
    }
}