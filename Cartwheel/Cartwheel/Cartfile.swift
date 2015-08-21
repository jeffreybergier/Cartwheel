//
//  Cartfile.swift
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

// MARK: Implement the Struct Type Cartfile

struct Cartfile: DependencyDefinable {
    
    var name: String
    var location: NSURL
    
    init(location: NSURL) {
        self.location = location
        self.name = location.lastPathComponent!
    }
    
    func encodableCopy() -> EncodableDependencyDefinable {
        return EncodableCartfile(location: self.location)
    }
    
    static func fileName() -> String {
        return "Cartfile"
    }
    
    static func writeEmptyToDirectory(directory: NSURL) -> NSError? {
        let blankFileURL = directory.URLByAppendingPathComponent(Cartfile.fileName(), isDirectory: false)
        let blankData = NSData()
        var error: NSError?
        blankData.writeToURL(blankFileURL, options: NSDataWritingOptions.DataWritingWithoutOverwriting, error: &error)
        return error
    }
    
}

extension Cartfile: Printable {
    var description: String {
        return "\(self.name) <\(self.location.path!)>"
    }
}

extension Cartfile: Hashable {
    var hashValue: Int {
        return self.name.hashValue
    }
}

extension Cartfile: Equatable {}
func ==(lhs: Cartfile, rhs: Cartfile) -> Bool {
    if lhs.hashValue == rhs.hashValue { return true } else { return false }
}

// MARK: Implement the Encodable Class Type

final class EncodableCartfile: NSObject, EncodableDependencyDefinable, ProtocolHackDependencyDefinable {
    
    var name: String
    var location: NSURL
    
    init(location: NSURL) {
        self.location = location
        self.name = location.lastPathComponent!
        super.init()
    }
    
    func decodedCopy() -> DependencyDefinable {
        return Cartfile(location: self.location)
    }
    
    required init(coder aDecoder: NSCoder) {
        let location = aDecoder.decodeObjectForKey("location") as! NSURL
        self.location = location
        self.name = location.lastPathComponent!
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.location, forKey: "location")
    }
    
}