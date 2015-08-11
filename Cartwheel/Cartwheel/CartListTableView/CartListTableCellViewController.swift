//
//  CartListTableCellViewController.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 4/28/15.
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

import Cocoa
import PureLayout_Mac
import CarthageKit
import ReactiveCocoa
import Commandant

final class CartListTableCellViewController: NSTableCellView {
        
    let contentView = CartListTableCellView()
    
    var cartfile: CWCartfile! {
        didSet {
            self.prepareCellForNewModelObject()
            self.updateCellWithNewModelObject()
        }
    }
    
    static let identifier = "CartListTableCellViewController"
    override var identifier: String? {
        get { return self.classForCoder.identifier }
        set { /* do nothing */ /* this setter is needed to please the compiler */ }
    }
    
    private func prepareCellForNewModelObject() {
        self.contentView.clearCellContents()
    }
    
    private func updateCellWithNewModelObject() {
        if let cartfileTitle = self.cartfile?.name {
            self.contentView.setPrimaryTextFieldString(cartfileTitle)
        } else {
            self.contentView.clearCellContents()
        }
    }
    
    private var configured = false
    
    func configureViewIfNeeded() {
        if self.configured == false {
            // configure the view
            self.addSubview(self.contentView)
            self.contentView.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsetsZero)
            self.contentView.viewDidLoad()
            
            // configure the button
            self.contentView.setPrimaryButtonTitle(NSLocalizedString("Update", comment: "Button to perform carthage update"))
            self.contentView.setPrimaryButtonAction("didClickUpdateCartfileButton:", forTarget: self)
            self.configured = true
        }
    }
    
    @objc private func didClickUpdateCartfileButton(sender: NSButton) {
        println("didClickUpdateCartfileButton -- Begin")
        var macBuildsInProgress = 0
        var iosBuildsInProgress = 0
        var watchBuildsInProgress = 0
        
        self.cartfile.project.updateDependencies()
            |> on(started: {
                println("Updating Dependencies")
            })
            |> on(completed: {
                println("Finished Updating Dependencies")
                self.cartfile.project.buildCheckedOutDependenciesWithConfiguration("", forPlatform: .Mac)
                    |> start(next: { build in
                        build
                            |> on(started: {
                                macBuildsInProgress++
                                println("Mac Build has Started. In Progress = \(macBuildsInProgress)")
                            })
                            |> on(completed: {
                                macBuildsInProgress--
                                println("Mac Build has Completed. In Progress = \(macBuildsInProgress)")
                            })
                            |> start()
                        
                    })
                self.cartfile.project.buildCheckedOutDependenciesWithConfiguration("", forPlatform: .iOS)
                    |> start(next: { build in
                        build
                            |> on(started: {
                                iosBuildsInProgress++
                                println("iOS Build has Started. In Progress = \(iosBuildsInProgress)")
                            })
                            |> on(completed: {
                                iosBuildsInProgress--
                                println("iOS Build has Completed. In Progress = \(iosBuildsInProgress)")
                            })
                            |> start()
                        
                    })
                self.cartfile.project.buildCheckedOutDependenciesWithConfiguration("", forPlatform: .watchOS)
                    |> start(next: { build in
                        build
                            |> on(started: {
                                watchBuildsInProgress++
                                println("WatchOS Build has Started. In Progress = \(watchBuildsInProgress)")
                            })
                            |> on(completed: {
                                watchBuildsInProgress--
                                println("WatchOS Build has Completed. In Progress = \(watchBuildsInProgress)")
                            })
                            |> start()
                        
                    })
            })
            |> start()


//        |> then(self.cartfile.project.buildCheckedOutDependenciesWithConfiguration("", forPlatform: .Mac))
//        |> then(self.cartfile.project.buildCheckedOutDependenciesWithConfiguration("", forPlatform: .iOS))
//        |> then(self.cartfile.project.buildCheckedOutDependenciesWithConfiguration("", forPlatform: .watchOS))
//        |> start(error: { error -> () in
//            println("something error: \(error)")
//            }, next: { build -> () in
//                println("something next – build: \(build)")
//                build.start(error: { error -> () in
//                    println("build error: \(error)")
//                    }, completed: { () -> () in
//                        println("build completed")
//                    }, interrupted: { () -> () in
//                        println("build interrupted")
//                    }, next: { locator -> () in
//                        println("build next: locator: \(locator)")
//                        if let something = locator.value {
//                            switch something.0 {
//                            case .Workspace(let url):
//                                println("locator.Workspace: \(url)")
//                            case .ProjectFile(let url):
//                                println("locator.ProjectFile: \(url)")
//                            }
//                        }
//                })
//        })
        
//        result?.start(error: {error -> () in
//            println("result1 error: \(error)")
//            }, completed: { () -> () in
//                println("result1 completed")
//                let resultMac = self.cartfile?.project.buildCheckedOutDependenciesWithConfiguration("", forPlatform: .Mac)
//                resultMac?.start(error: {error -> () in
//                    println("resultMac1 error: \(error)")
//                    }, completed: { () -> () in
//                        println("resultMac1 completed")
//                    }, interrupted: { () -> () in
//                        println("resultMac1 interrupted")
//                    }, next: { build -> () in
//                        println("resultMac1 next: \(build)")
//                        build.start(error: {error -> () in
//                            println("resultMac2 error: \(error)")
//                            }, completed: { () -> () in
//                                println("resultMac2 completed")
//                            }, interrupted: { () -> () in
//                                println("resultMac2 interrupted")
//                            }, next: { build -> () in
//                                println("resultMac2 next: \(build)")
//                        })
//                })
//                let resultiOS = self.cartfile?.project.buildCheckedOutDependenciesWithConfiguration("", forPlatform: .iOS)
//                resultiOS?.start(error: {error -> () in
//                    println("resultiOS1 error: \(error)")
//                    }, completed: { () -> () in
//                        println("resultiOS1 completed")
//                    }, interrupted: { () -> () in
//                        println("resultiOS1 interrupted")
//                    }, next: { build -> () in
//                        println("resultiOS1 next: \(build)")
//                        build.start(error: {error -> () in
//                            println("resultiOS2 error: \(error)")
//                            }, completed: { () -> () in
//                                println("resultiOS2 completed")
//                            }, interrupted: { () -> () in
//                                println("resultiOS2 interrupted")
//                            }, next: { build -> () in
//                                println("resultiOS2 next: \(build)")
//                        })
//                })
//                let resultWatch = self.cartfile?.project.buildCheckedOutDependenciesWithConfiguration("", forPlatform: .watchOS)
//                resultWatch?.start(error: {error -> () in
//                    println("resultWatch1 error: \(error)")
//                    }, completed: { () -> () in
//                        println("resultWatch1 completed")
//                    }, interrupted: { () -> () in
//                        println("resultWatch1 interrupted")
//                    }, next: { build -> () in
//                        println("resultWatch1 next: \(build)")
//                        build.start(error: {error -> () in
//                            println("resultWatch2 error: \(error)")
//                            }, completed: { () -> () in
//                                println("resultWatch2 completed")
//                            }, interrupted: { () -> () in
//                                println("resultWatch2 interrupted")
//                            }, next: { build -> () in
//                                println("resultWatch2 next: \(build)")
//                        })
//                })
//
//            }, interrupted: { () -> () in
//                println("result1 interrupted")
//            }, next: { () -> () in
//                println("result1 next:")
//        })

        println("didClickUpdateCartfileButton -- End")
    }
    
    // MARK: Special Property used to Calculate Row Height
    
    var viewHeightForTableRowHeightCalculation: CGFloat {
        return self.contentView.viewHeightForTableRowHeightCalculation
    }
}
