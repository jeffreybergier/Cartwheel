//
//  CWCartfile.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 5/18/15.
//  Copyright (c) 2015 Saturday Apps. All rights reserved.
//

import Foundation

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