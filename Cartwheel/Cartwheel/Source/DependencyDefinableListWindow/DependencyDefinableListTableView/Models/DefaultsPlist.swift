//
//  DefaultsPlist.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 8/21/15.
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
import XCGLogger

struct DefaultsPlist {
    var directorySearchRecursion: Int
    var storageDirectory: String
    var storageFile: String
    
    init() {
        // declare the needed values
        let directorySearchRecursion: NSNumber?
        let storageDirectory: String?
        let storageFile: String?
        
        // read the plist from disk
        var dataError: NSError?
        var plistError: NSError?
        if let plistURL = NSBundle.mainBundle().URLForResource("CartwheelDefaults", withExtension: "plist"),
            let data = NSData(contentsOfURL: plistURL, options: nil, error: &dataError),
            let plist = NSPropertyListSerialization.propertyListWithData(data, options: NSPropertyListReadOptions.allZeros, format: nil, error: &plistError) as? NSDictionary {
                
                // parse the plist
                directorySearchRecursion = plist["DirectorySearchRecursion"] as? NSNumber
                storageDirectory = plist["StorageDirectory"] as? String
                storageFile = plist["StorageFile"] as? String
        } else {
            // handle errors
            directorySearchRecursion = .None
            storageDirectory = .None
            storageFile = .None
            XCGLogger.defaultInstance().warning("Error Reading Plist from Disk. Using Defaults. PlistError: \(plistError) – DataError: \(dataError)")
        }
        
        // populate properties with values
        self.directorySearchRecursion = directorySearchRecursion?.integerValue !! 4
        self.storageDirectory = storageDirectory !! "Cartwheel"
        self.storageFile = storageFile !! "cartwheel.bin"
    }
}
