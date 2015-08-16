//
//  CWCartfile.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 5/18/15.
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

import CarthageKit

// MARK: CWCartfile Struct

struct CWCartfile {
    var url: NSURL
    var project: Project
    var parentDirectory: NSURL {
        return self.url.parentDirectory
    }
    var name: String {
        return self.url.parentDirectory.lastPathComponent!
    }
    
    init?(url: NSURL) {
        if url.lastPathComponent?.lowercaseString == CWCartfile.defaultsPlist.cartfileFileName.lowercaseString {
            self.url = url
            self.project = CarthageKit.Project(directoryURL: url.parentDirectory)
        } else {
            return nil
        }
    }
    
    // defaultsPlist requires disk activity so I only want that to happen once in the lifecycle of the app
    // however, every cartfile that is initalized needs to check to make sure it has a valid URL
    // this defaults plist is where it gets the name it needs
    // creating this private static constant allows me to always check for a valid URL
    // while not having to read from disk every time a cartfile is initialized
    private static let defaultsPlist = CWDefaultsPlist(something: true)
}

// MARK: Get Cartfiles from URLs

extension CWCartfile {
    
    static func cartfilesFromURL(url: NSURL) -> [CWCartfile]? {
        let cartfiles = url.extractFilesRecursionDepth(defaultsPlist.cartfileDirectorySearchRecursion)?.filter() { url -> Bool in
            if let cartfile = CWCartfile(url: url) { return true } else { return false }
        }.map() { url -> CWCartfile in
            return CWCartfile(url: url)!
        }
        
        if let cartfiles = cartfiles {
            if cartfiles.count > 0 { return cartfiles } else { return .None }
        }
        
        return .None
    }
    
    static func cartfilesFromURL(URLs: [AnyObject]) -> [CWCartfile]? {
        let filteredURLs = URLs.filter() { object -> Bool in
            if let url = object as? NSURL { return true } else { return false }
            }.map() { object -> NSURL in
                return object as! NSURL
        }
        
        let cartfiles = filteredURLs.map() { url -> [CWCartfile]? in
            // map is used twice here because cartfilesFromURL can be intensie and I don't want to run it twice in order to filter and then map
            return CWCartfile.cartfilesFromURL(url)
            }.filter() { array -> Bool in
                if let array = array { return true } else { return false }
            }.map() { array -> [CWCartfile] in
                return array!
        }
        
        let mergedCartfiles = Array.merge(cartfiles)
        if mergedCartfiles.count > 0 { return mergedCartfiles } else { return .None }
    }
}

// MARK: Printable

extension CWCartfile: Printable {
    var description: String {
        return "CWCartfile <\(self.name)>"
    }
}

// MARK: Hashable

extension CWCartfile: Hashable {
    var hashValue: Int {
        return self.url.path!.hashValue
    }
}

// MARK: Equatable

func ==(lhs: CWCartfile, rhs: CWCartfile) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

// MARK: CWEncodableCartfile

extension CWCartfile {
    func encodableCopy() -> CWEncodableCartfile {
        return CWEncodableCartfile(cartfile: self)
    }
}

final class CWEncodableCartfile: NSObject, NSCoding {
    
    let url: NSURL
    
    init(cartfile: CWCartfile) {
        self.url = cartfile.url
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        let url: AnyObject? = aDecoder.decodeObjectForKey("locationOnDisk")
        self.url = url as! NSURL
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.url, forKey: "locationOnDisk")
    }
    
    func decodedCartfile() -> CWCartfile {
        return CWCartfile(url: self.url)!
    }
}