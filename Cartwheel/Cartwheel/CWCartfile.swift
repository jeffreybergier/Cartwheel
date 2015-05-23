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

class CWCartfile: NSObject, NSCoding {
    var locationOnDisk: NSURL
    
    init(locationOnDisk: NSURL) {
        self.locationOnDisk = locationOnDisk
        super.init()
    }
    
    // MARK: NSCoding
    
    required init(coder aDecoder: NSCoder) {
        let locationOnDisk: AnyObject? = aDecoder.decodeObjectForKey("locationOnDisk")
        self.locationOnDisk = locationOnDisk as! NSURL
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.locationOnDisk, forKey: "locationOnDisk")
    }
}

// MARK: Printable

extension CWCartfile: Printable {
    override var description: String {
        return "CWCartfile" + " " + (NSString(format: "%p:", self) as String) + " " + "\(self.locationOnDisk.path)"
    }
}

// MARK: Hashable

extension CWCartfile: Hashable {
    override var hashValue: Int {
        return self.locationOnDisk.path!.hashValue
    }
}

// MARK: Equatable

func ==(lhs: CWCartfile, rhs: CWCartfile) -> Bool {
    return lhs.hashValue == rhs.hashValue
}