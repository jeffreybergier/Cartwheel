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
import ObserverSet
import XCGLogger
import Async

class CWCartfileDataSource {
    
    // MARK: Properties (Private)
    
    private let log = XCGLogger.defaultInstance()
    private let defaultsPlist = CWDefaultsPlist()
    
    // MARK: Properties (Internal)
    
    let cartfileObserver = ObserverSet<Void>()
    
    private(set) var cartfiles = [CWCartfile]() {
        didSet {
            Async.main {
                // notify observers on main thread
                self.cartfileObserver.notify()
            }.userInitiated {
                // save to disk in the background
                if self.cartfileStorageFolderExists() == false {
                    self.log.info("Cartfile storage folder does not exist, creating it.")
                    self.createCartfileStorageFolder()
                }
                var writeToDiskError: NSError?
                let archivableCartfiles = self.cartfiles.map() { cartfile -> CWEncodableCartfile in
                    return cartfile.encodableCopy()
                }
                NSKeyedArchiver.archivedDataWithRootObject(archivableCartfiles).writeToURL(self.cartfileStorageFolder.URLByAppendingPathComponent(self.defaultsPlist.cartfileListSaveName), options: nil, error: &writeToDiskError)
                
                if let error = writeToDiskError {
                    self.log.error("Error saving cartfiles to disk: \(error)")
                }
            }
        }
    }
    
    // MARK: Mutating Methods (Internal)
    
    func appendCartfile(newCartfile: CWCartfile) {
        self.cartfiles = self.insertUniqueItems([newCartfile], intoCollection: self.cartfiles, atIndex: self.cartfiles.count)
    }
    
    func appendCartfiles(newCartfiles: [CWCartfile]) {
        self.cartfiles = self.insertUniqueItems(newCartfiles, intoCollection: self.cartfiles, atIndex: self.cartfiles.count)
    }
    
    func insertCartfiles(newCartfiles: [CWCartfile], atIndex index: Int) {
        self.cartfiles = self.insertUniqueItems(newCartfiles, intoCollection: self.cartfiles, atIndex: index)
    }
    
    func moveCartfilesAtIndexes(indexes: NSIndexSet, toIndex index: Int) {
        self.cartfiles = self.moveItemsAtIndexes(indexes.ranges, toIndex: index, ofCollection: self.cartfiles)
    }
    
    func writeBlankCartfileToDirectoryPath(directory: NSURL) -> (finalURL: NSURL, error: NSError?) {
        return self.writeEmptyFileToDirectory(directory, withName: self.defaultsPlist.cartfileFileName)
    }
    
    // MARK: Pure Functions – Don't Rely on or Modify State (Private)
    
    private func insertUniqueItems<T: Equatable>(items: [T], intoCollection inputCollection: [T], atIndex index: Int) -> [T] {
        //let uniqueItems = collectionOfItemsUniqueToCollection(items, andCollection: inputCollection)
        
        var outputCollection = inputCollection
        var mutableIndex = index
        if index < inputCollection.count {
            for item in items {
                outputCollection.insert(item, atIndex: mutableIndex)
                mutableIndex++
            }
        } else {
            outputCollection += items
        }
        
        return outputCollection
    }
    
    private func moveItemsAtIndexes<T: Equatable>(indexes: [Range<Int>], toIndex index: Int, ofCollection inputCollection: [T]) -> [T] {
        // gather the items that need to be moved
        let movedItems = collectionByExtractingItemsAtIndexes(indexes, fromCollection: inputCollection)
        // count the number of items that were before the target index so the index can be adjusted
        let indexAdjustment = numberOfItemsInIndexes(indexes, beforeIndex: index)
        // get a collection that has had all the moved items removed from it
        let collectionSansMovedItems = collectionByRemovingItemsAtIndexes(indexes, fromCollection: inputCollection)
        // insert the moved items into the correct index of collectionSansMovedItems
        let outputCollection = insertUniqueItems(movedItems, intoCollection: collectionSansMovedItems, atIndex: index - indexAdjustment)

        return outputCollection
    }

    // MARK: Writing to Disk (Private)
    
    private func writeEmptyFileToDirectory(directory: NSURL, withName name: String) -> (finalURL: NSURL, error: NSError?) {
        let blankFileURL = directory.URLByAppendingPathComponent(name, isDirectory: false)
        let blankData = NSData()
        var error: NSError?
        blankData.writeToURL(blankFileURL, options: NSDataWritingOptions.DataWritingWithoutOverwriting, error: &error)
        return (finalURL: blankFileURL, error: error)
    }
    
    private let fileManager = NSFileManager.defaultManager()
    private let cartfileStorageFolder: NSURL = {
        let array = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)
        return NSURL(fileURLWithPath: (array.last as! String).stringByAppendingPathComponent(CWDefaultsPlist().cartfileListSaveLocation))!
    }()
    
    private func cartfileStorageFolderExists() -> Bool {
        return self.fileManager.fileExistsAtPath(self.cartfileStorageFolder.path!)
    }
    
    private func createCartfileStorageFolder() -> Bool {
        return self.fileManager.createDirectoryAtPath(self.cartfileStorageFolder.path!, withIntermediateDirectories: true, attributes: nil, error: nil)
    }
    
    // MARK: Initialization
    
    init() {
        self.cartfiles = self.readCartfilesFromDisk()
    }
    
    private func readCartfilesFromDisk() -> [CWCartfile] {
        let fileURL = self.cartfileStorageFolder.URLByAppendingPathComponent(self.defaultsPlist.cartfileListSaveName)
        
        var fileReachableError: NSError?
        let fileURLIsReachable = fileURL.checkResourceIsReachableAndReturnError(&fileReachableError)
        if let error = fileReachableError {
            self.log.error("Error reading Cartfiles from disk: \(error)")
        }
        
        if fileURLIsReachable == true {
            var readFromDiskError: NSError?
            if let dataOnDisk = NSData(contentsOfURL: fileURL, options: nil, error: &readFromDiskError),
                let unarchivedObjects = NSKeyedUnarchiver.unarchiveObjectWithData(dataOnDisk) as? [AnyObject] {
                    let cartfiles = Array.filterOptionals(unarchivedObjects.map({ object -> CWCartfile? in
                        if let encodableCartfile = object as? CWEncodableCartfile {
                            return encodableCartfile.decodedCartfile()
                        }
                        return .None
                    }))
                    return cartfiles
            }
            if let error = readFromDiskError {
                self.log.error("Error reading Cartfiles from disk: \(readFromDiskError)")
            }
        }
        
        return [CWCartfile]()
    }
}
