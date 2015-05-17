//: Playground - noun: a place where people can play

import Cocoa

let fileManager = NSFileManager.defaultManager()

let appSupportPath: String = {
    let array = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)
    
    if let directoryURLString = array.last as? String {
        return directoryURLString + "/" + "Cartwheel" + "/"
    } else {
        fatalError("App support directory not returned by file manager")
    }
    }()

let cartfilesArrayPath: String = {
    return appSupportPath + "cartfiles.array"
    }()

func directoryExists(#fileManager: NSFileManager, #path: String) -> Bool {
    var success = false
    
    if fileManager.fileExistsAtPath(path) == false {
        println("Directory does not exist. Going to make it")
        if fileManager.createDirectoryAtPath(path, withIntermediateDirectories: false, attributes: nil, error: nil) == true {
            println("Directory Created Successfully")
            success = true
        } else {
            println("Directory Creation Failed") // Handle errors
            success = false
        }
    } else {
        println("Directory already exists")
        success = true
    }
    
    return success
}

if directoryExists(fileManager: fileManager, path: appSupportPath) == true {
    println("if statement succeeded")
}