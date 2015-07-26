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

import Foundation

// MARK: CWCartfile Struct

struct CWCartfile {
    var url: NSURL
    var name: String {
        if let components = self.url.pathComponents {
            let index = components.count - 2
            if let parentFolderName = components[safe: index] as? String {
                return parentFolderName
            }
        }
        return ""
    }
    
    init(url: NSURL) {
        self.url = url
    }
}

// MARK: Get Cartfiles from URLs

extension CWCartfile {
    
    static func cartfilesFromURL(url: NSURL) -> [CWCartfile]? {
        let defaultsPlist = CWDefaultsPlist()
        if let recursedFiles = url.extractFilesRecursionDepth(defaultsPlist.cartfileDirectorySearchRecursion) {
            let optionalCartfiles = recursedFiles.map { url -> CWCartfile? in
                if url.lastPathComponent?.lowercaseString == defaultsPlist.cartfileFileName.lowercaseString {
                    return CWCartfile(url: url) } else { return .None }
            }
            let cartfiles = Array.filterOptionals(optionalCartfiles)
            if cartfiles.count > 0 { return cartfiles } else { return .None }
        }
        return .None
    }
    
    static func cartfilesFromURL(URLs: [AnyObject]) -> [CWCartfile]? {
        let optionalURLs = URLs.map { object -> NSURL? in
            if let url = object as? NSURL { return url } else { return .None }
        }
        let filteredURLs = Array.filterOptionals(optionalURLs)
        let optionalCartfiles = filteredURLs.map { url -> [CWCartfile]? in
            return self.cartfilesFromURL(url)
        }
        let mergedCartfiles = Array.merge(optionalCartfiles)
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
        return CWCartfile(url: self.url)
    }
}