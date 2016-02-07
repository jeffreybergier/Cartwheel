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
    init(url: NSURL)
    init?(dictionary: NSDictionary)
    func dictionaryVersion() -> NSDictionary
}

struct Cartfile: DependencyDefinable {
    var title: String
    var url: NSURL
    
    init(url: NSURL) {
        self.title = url.URLByDeletingLastPathComponent!.lastPathComponent!
        self.url = url
    }
    
    init?(dictionary: NSDictionary) {
        if let url = dictionary["url"] as? NSURL {
            self.init(url: url)
        } else {
            return nil
        }
    }
    
    func dictionaryVersion() -> NSDictionary {
        return ["url" : self.url]
    }
}
