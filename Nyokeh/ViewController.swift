//
//  ViewController.swift
//  Nyokeh
//
//  Created by Anton Zering on 29.07.15.
//  Copyright (c) 2015–2016 Anton Zering. All rights reserved.
//

import Cocoa
import Alamofire

struct Config {
  var url: String = ""
}



class ViewController: NSViewController {
  @IBOutlet weak var prefWindow: NSWindow!
  
  var config: NSUserDefaults!
  let api = NyokehApi()
  let tempFileName = "/tmp/screencap.png"
  
  override func viewDidLoad() {
    super.viewDidLoad()

    config = NSUserDefaults.standardUserDefaults()

    api.serverUrl = config.stringForKey("server")
    api.apiKey = config.stringForKey("authKey")
  }
  
  ///
  ///
  ///
  func notify(url: String) {
    NSSound(named: "Bottle.aiff")?.play()
  }
  
  func copyUrlToClipboard(url: String) {
    let pasteBoard = NSPasteboard.generalPasteboard()
    
    
    // first you must clear the contents of the clipboard in order to write to it.
    pasteBoard.clearContents()
    
    // now read write our String and an Array with 1 item at index 0
    pasteBoard.writeObjects([url]);
  }

  
  func uploadFile(filePath: String) {
    api.uploadFile(
      NSURL(fileURLWithPath: filePath),
      
      completion: { fileUrl in
        self.notify(fileUrl)
        
        self.config.setValue(fileUrl, forKey: "lastUrl")
        
        if (self.config.boolForKey("shallOpenInBrowser")) {
          self.openInBrowser(fileUrl)
        }
        
        if (self.config.boolForKey("shallCopyToClipboard")) {
          self.copyUrlToClipboard(fileUrl)
        }
      }
    )
  }
  
  func openInBrowser(url: String) {
    NSWorkspace.sharedWorkspace().openURL(NSURL(string: url)!)
  }
  
  @IBAction func takeScreenshot(sender: AnyObject) {
    let task = NSTask.launchedTaskWithLaunchPath(
      "/usr/sbin/screencapture",
      arguments: ["-C", "-W", tempFileName]
    )
    
    task.waitUntilExit()
    
    if (task.terminationStatus != 0) {
      return
    }

    uploadFile(tempFileName)
  }
  
  @IBAction func testConnection(sender: AnyObject) {
    api.testConnection { isValid in
      let alert = NSAlert()
      alert.messageText = "Info"
      alert.informativeText = isValid ? "Okay!" : "Error! Please check credentials."
      alert.runModal();
    }
  }
  
  
  @IBAction func openInBrowserHandler(sender: AnyObject) {
    if let fileUrl = self.config.stringForKey("lastUrl") {
      self.openInBrowser(fileUrl)
    }
  }

  @IBAction func showPreferences(sender: AnyObject) {
    prefWindow.makeKeyAndOrderFront(self)
    NSApp.activateIgnoringOtherApps(true)
  }
}
