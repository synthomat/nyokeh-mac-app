//
//  AppDelegate.swift
//  Nyokeh
//
//  Created by Anton Zering on 29.07.15.
//  Copyright (c) 2015 Anton Zering. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: NSWindow!

  @IBOutlet weak var menu: NSMenu!
  
  var statusItem: NSStatusItem!
  let popover = NSPopover()
  
  
  
  func applicationDidFinishLaunching(aNotification: NSNotification) {
    // Insert code here to initialize your application
    statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    statusItem.image = NSImage(named: "NyokehMenuIcon")
    statusItem.button?.action = Selector("togglePopover:")

  
    popover.contentViewController = UploadHistoryController(nibName: "UploadHistoryController", bundle: nil)
    
    //statusItem.title = "Nyokeh"
    //statusItem.menu = menu;
    
    
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
  }
  
  func showPopover(sender: AnyObject?) {
    if let button = statusItem.button {
      popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: NSMinYEdge)
    }
  }
  
  func closePopover(sender: AnyObject?) {
    popover.performClose(sender)
  }

  @IBAction func quitApplication(sender: AnyObject) {
    NSApplication.sharedApplication().terminate(self)
  }
  
  func togglePopover(sender: AnyObject?) {
    if popover.shown {
      closePopover(sender)
    } else {
      showPopover(sender)
    }
  }
}

