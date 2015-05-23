//: Playground - noun: a place where people can play

import Cocoa

// MARK: Defaults.plist file
let defaults: [String : AnyObject]? = {
    var dataError: NSError?
    var plistError: NSError?
    if let url = NSBundle.mainBundle().URLForResource("CartwheelDefaults", withExtension: "plist") {
        if let data = NSData(contentsOfURL: url, options: nil, error: &dataError) {
            if let plist = NSPropertyListSerialization.propertyListWithData(data, options: NSPropertyListReadOptions.allZeros, format: nil, error: &plistError) as? [String : AnyObject] {
                for (key, value) in plist {
                    println("Key: \(key) -> Value: \(value)")
                }
                return plist
            }
        }
    }
    return nil
}()

println(defaults)
