//
//  CWCartfileDataSource.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 5/10/15.
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

class CWCartfileDataSource {
    
    private var _cartfiles: [CWCartfile]? {
        didSet {
            let cartfiles: [CWCartfile]
            if let verifiedCartfiles = _cartfiles {
                cartfiles = verifiedCartfiles
            } else {
                cartfiles = []
            }
            let blankData = NSKeyedArchiver.archivedDataWithRootObject(cartfiles)
            if self.fileManager.createFileAtPath(self.cartfilesArrayPath, contents: blankData, attributes: nil) == true {
            } else {
                fatalError("CWCartfileDataSource: Tried to save cartFiles to disk and failed.")
            }
        }
    }
    var cartiles: [CWCartfile] {
        get {
            if let cartFiles = _cartfiles {
                return cartFiles
            } else {
                if self.pathExists(fileManager: self.fileManager, path: self.appSupportPath) == true {
                    if self.fileManager.fileExistsAtPath(self.cartfilesArrayPath) == true {
                        if let dataOnDisk = self.fileManager.contentsAtPath(self.appSupportPath),
                            let cartfilesArray = NSKeyedUnarchiver.unarchiveObjectWithData(dataOnDisk) as? [CWCartfile] {
                                _cartfiles = cartfilesArray
                             return cartfilesArray
                        }
                    }
                }
            }
            _cartfiles = []
            return []
        }
    }
    
    func addCartfile(newFile: CWCartfile) {
        
    }
    
    let fileManager = NSFileManager.defaultManager()
    let appSupportPath: String = {
        let array = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)
        
        if let directoryURLString = array.last as? String {
            return directoryURLString + "/" + "Cartwheel" + "/"
        } else {
            fatalError("App support directory not returned by file manager")
        }
    }()
    
    lazy var cartfilesArrayPath: String = {
        return self.appSupportPath + "cartfiles.array"
    }()
    
    private func pathExists(#fileManager: NSFileManager, path: String) -> Bool {
        var success = false
        
        if fileManager.fileExistsAtPath(path) == false {
            if fileManager.createDirectoryAtPath(path, withIntermediateDirectories: false, attributes: nil, error: nil) == true {
                success = true
            } else {
                success = false
            }
        } else {
            success = true
        }
        
        return success
    }
    
    class var sharedInstance: CWCartfileDataSource {
        struct Static {
            static var instance: CWCartfileDataSource?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = CWCartfileDataSource()
        }
        
        return Static.instance!
    }
    
    class CWCartfile: NSObject, NSCoding {
        var locationOnDisk: NSURL
        
        init(locationOnDisk: NSURL) {
            self.locationOnDisk = locationOnDisk
            super.init()
        }
        
        @objc required init(coder aDecoder: NSCoder) {
            let locationOnDisk: AnyObject? = aDecoder.decodeObjectForKey("locationOnDisk")
            if let locationOnDisk = locationOnDisk as? NSURL {
                self.locationOnDisk = locationOnDisk
            } else {
                fatalError("CWCartfile: Failed to initalize from NSCoder")
            }
        }
        
        @objc func encodeWithCoder(aCoder: NSCoder) {
            aCoder.encodeObject(self.locationOnDisk, forKey: "locationOnDisk")
        }
    }
}
