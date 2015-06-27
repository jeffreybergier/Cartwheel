//: Playground - noun: a place where people can play

import Cocoa
import XCPlayground

struct InterfaceElements {
    var addButton: NSButton = {
        let button = NSButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        }()
    var createNewButton: NSButton = {
        let button = NSButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        }()
    var filterField: NSSearchField = {
        let filterField = NSSearchField()
        filterField.translatesAutoresizingMaskIntoConstraints = false
        return filterField
        }()
    
    var allViews: [NSView] {
        return [addButton, createNewButton, filterField]
    }
}

private func configure(#addButton: NSButton) {
    if let _ = addButton.superview {
        addButton.setButtonType(.MomentaryPushInButton)
        addButton.bezelStyle = .RoundedBezelStyle
        addButton.title = NSLocalizedString("Add Cartfile", comment: "Button to Add a Cartfile to Cartwheel")
        addButton.action = "didClickAddCartFileButton:"
    } else {
        fatalError("CartListView: Tried to configure the AddButton before it was in the view hierarchy.")
    }
}

private func configure(#createNewButton: NSButton) {
    if let _ = createNewButton.superview {
        createNewButton.setButtonType(.MomentaryPushInButton)
        createNewButton.bezelStyle = .RoundedBezelStyle
        createNewButton.title = NSLocalizedString("Create Cartfile", comment: "Button to Add a Cartfile to Cartwheel")
        createNewButton.action = "didClickCreateNewCartFileButton:"
    } else {
        fatalError("CartListView: Tried to configure the AddButton before it was in the view hierarchy.")
    }
}

let ui = InterfaceElements()
let stackView = NSStackView(views: ui.allViews)
stackView.orientation = .Horizontal
configure(addButton: ui.addButton)
configure(createNewButton: ui.createNewButton)
stackView.wantsLayer = true
stackView.frame = NSRect(x: 0, y: 0, width: 400, height: 80)
stackView.layer!.backgroundColor = NSColor.blackColor().CGColor

XCPShowView("stackView", stackView)