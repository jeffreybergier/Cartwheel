//
//  DDSourceListViewControllerContent.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 2/8/16.
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

import JSBUtils
import Foundation

extension DependencyDefinableSourceListViewController {
    struct Model {
        var cartfiles: [Cartfile]
        var podfiles: [DependencyDefinable]
        
        init() {
            self.cartfiles = []
            self.podfiles = []
        }
        
        init(cartfiles: [Cartfile], podfiles: [DependencyDefinable]) {
            self.cartfiles = cartfiles
            self.podfiles = podfiles
        }
        
        init(diskManager: JSBDictionaryPLISTPreferenceManager) {
            let readLocation = JSBDictionaryPLISTPreferenceManager.UserFileLocation.AppDirectoryWithinAppSupportDirectory(lastPathComponent: "Cartwheel.plist")
            let untypedDictionary = try? diskManager.dictionaryByReadingPLISTFromDiskLocation(readLocation)
            let contentDictionary = untypedDictionary as? [String : [NSDictionary]]
            
            let cartfilesArray: [Cartfile]
            if let cartfileDictionaryArray = contentDictionary?["Cartfile"] {
                cartfilesArray = cartfileDictionaryArray.map() { dictionary -> Cartfile? in
                    return Cartfile(dictionary: dictionary)
                    }.filter() { cartfile -> Bool in
                        return cartfile != nil
                    }.map() { cartfile -> Cartfile in
                        return cartfile!
                }
            } else {
                cartfilesArray = []
            }
            
            self.cartfiles = cartfilesArray
            self.podfiles = []
        }
        
        mutating func appendContent(newCartfiles: [Cartfile], newPodfiles: [DependencyDefinable]) {
            self.cartfiles += newCartfiles
            self.podfiles += newPodfiles
        }
        
        enum RemoveError: ErrorType {
            case UnhandledType
            case OriginalNotFound
        }
        
        mutating func removeItem(itemToRemove: DependencyDefinable) throws {
            if (itemToRemove is Cartfile) == false && (itemToRemove is String) == false {
                throw RemoveError.UnhandledType
            }
            
            if let cartfile = itemToRemove as? Cartfile, let deleteIndex = self.cartfiles.indexOf(cartfile) {
                self.cartfiles.removeAtIndex(deleteIndex)
            } else {
                throw RemoveError.OriginalNotFound
            }
//            else if let podfile = DependencyDefinable as? Podfile, let deleteIndex = self.podfiles.indexOf(podfile) {
//                self.podfiles.removeAtIndex(deleteIndex)
//            }
        }
        
        func nodeVersion() -> [SourceListNode<DependencyDefinable>] {
            let cartfileChildren = self.cartfiles.map() { cartfile -> SourceListNode<DependencyDefinable> in
                return SourceListNode(title: cartfile.title, item: cartfile)
            }
            let podfileChildren = self.podfiles.map() { podfile -> SourceListNode<DependencyDefinable> in
                return SourceListNode(title: podfile.title, item: podfile)
            }
            let cartfileParent = SourceListNode(title: "Cartfiles", children: cartfileChildren)
            let podfileParent = SourceListNode(title: "Podfiles", children: podfileChildren)
            
            return [cartfileParent] + [podfileParent]
        }
        
        func saveToDiskWithManager(diskManager: JSBDictionaryPLISTPreferenceManager) throws {
            let writableCartfiles = self.cartfiles.map() { cartfile -> NSDictionary in
                return cartfile.dictionaryVersion()
            }
            let writeablePodfiles = self.podfiles.map() { podfile -> NSDictionary in
                return podfile.dictionaryVersion()
            }
            let dictionary = [
                "Cartfile" : writableCartfiles,
                "Podfile" : writeablePodfiles
            ]
            
            do {
                try diskManager.writePLISTDictionary(dictionary, toLocation: .AppDirectoryWithinAppSupportDirectory(lastPathComponent: "Cartwheel.plist"), options: .AtomicWrite)
            } catch {
                throw error
            }
        }
    }
}
