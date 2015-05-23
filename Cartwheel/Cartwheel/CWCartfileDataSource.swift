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
    
    // MARK: Internal Properties
    
    private(set) var cartfiles = Set<CWCartfile>() {
        didSet {
            if self.cartfileStorageFolderExists() == false {
                NSLog("CWCartfileDataSource: Cartfile storage folder does not exist, creating it.")
                self.createCartfileStorageFolder()
            }
            
            var writeToDiskError: NSError?
            NSKeyedArchiver.archivedDataWithRootObject(self.cartfiles).writeToURL(self.cartfileStorageFolder.URLByAppendingPathComponent(self.cartfilesArrayFileName), options: nil, error: &writeToDiskError)
            
            if let error = writeToDiskError {
                NSLog("CWCartfileDataSource: Error saving cartfiles to disk: \(error)")
            }
        }
    }
    
    // MARK: Internal Methods
    
    func addCartfile(newCartfile: CWCartfile) {
        self.cartfiles.insert(newCartfile)
    }
    
    // MARK: Handle Saving Cartfiles to disk
    
    private let fileManager = NSFileManager.defaultManager()
    private let cartfilesArrayFileName = "cartfiles.array"
    private let cartfileStorageFolder: NSURL = {
        let array = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)
        return NSURL(fileURLWithPath: (array.last as! String).stringByAppendingPathComponent("Cartwheel"))!
    }()
    
    private func cartfileStorageFolderExists() -> Bool {
        return self.fileManager.fileExistsAtPath(self.cartfileStorageFolder.path!)
    }
    
    private func createCartfileStorageFolder() -> Bool {
        return self.fileManager.createDirectoryAtPath(self.cartfileStorageFolder.path!, withIntermediateDirectories: true, attributes: nil, error: nil)
    }
    
    // MARK: Handle Launching and Singleton
    
    private func readCartfilesFromDisk() -> Set<CWCartfile> {
        let fileURL = self.cartfileStorageFolder.URLByAppendingPathComponent(self.cartfilesArrayFileName)
        var fileReachableError: NSError?
        //if self.fileManager.fileExistsAtPath(fileURL.path!) == true {
        if fileURL.checkResourceIsReachableAndReturnError(&fileReachableError) == true {
            var readFromDiskError: NSError?
            if let dataOnDisk = NSData(contentsOfURL: fileURL, options: nil, error: &readFromDiskError),
                let cartfilesArray = NSKeyedUnarchiver.unarchiveObjectWithData(dataOnDisk) as? Set<CWCartfile> {
                    return cartfilesArray
            } else {
                NSLog("CWCartfileDataSource: Error reading Cartfiles from disk: \(readFromDiskError)")
            }
        } else {
            NSLog("CWCartfileDataSource: Error reading Cartfiles from disk: \(fileReachableError)")
        }
        return []
    }
    
    class var sharedInstance: CWCartfileDataSource {
        struct Static {
            static var instance: CWCartfileDataSource?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = CWCartfileDataSource()
            Static.instance?.cartfiles = Static.instance!.readCartfilesFromDisk()
        }
        
        return Static.instance!
    }
}
