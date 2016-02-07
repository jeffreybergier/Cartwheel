//
//  DependencyDefinable.swift
//  Cartwheel
//
//  Created by aGitated crAnberries on 2/6/16.
//  Copyright © 2016 Saturday Apps. All rights reserved.
//

import Foundation

protocol DependencyDefinable {
    var title: String { get set }
    var url: NSURL { get set }
    init?(url: NSURL)
    init?(dictionary: NSDictionary)
    func dictionaryVersion() -> NSDictionary
}

struct Cartfile: DependencyDefinable {
    var title: String
    var url: NSURL
    
    init?(url: NSURL) {
        if let fileName = url.lastPathComponent,
            let title = url.URLByDeletingLastPathComponent?.lastPathComponent
            where fileName.lowercaseString == "Cartfile".lowercaseString
        {
            self.title = title
            self.url = url
        } else {
            return nil
        }
    }
    
    init?(dictionary: NSDictionary) {
        if let urlData = dictionary["URLDataBlob"] as? NSData, url = NSKeyedUnarchiver.unarchiveObjectWithData(urlData) as? NSURL {
            self.init(url: url)
        } else {
            return nil
        }
    }
    
    func dictionaryVersion() -> NSDictionary {
        let data = NSKeyedArchiver.archivedDataWithRootObject(self.url)
        return ["URLDataBlob" : data]
    }
}
