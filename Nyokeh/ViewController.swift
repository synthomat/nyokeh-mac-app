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
  
  var config: UserDefaults!
  let api = NyokehApi()
  let tempFileName = "/tmp/screencap.png"
  
  override func viewDidLoad() {
    super.viewDidLoad()

    config = UserDefaults.standard

    api.serverUrl = config.string(forKey: "server")
    api.apiKey = config.string(forKey: "authKey")
  }
  
  ///
  ///
  ///
  func notify(_ url: String) {
    NSSound(named: "Bottle.aiff")?.play()
  }
  
  func copyUrlToClipboard(_ url: String) {
    let pasteBoard = NSPasteboard.general()
    
    
    // first you must clear the contents of the clipboard in order to write to it.
    pasteBoard.clearContents()
    
    // now read write our String and an Array with 1 item at index 0
    pasteBoard.writeObjects([url as NSPasteboardWriting]);
  }

  
  func uploadFile(_ filePath: String) {
    api.uploadFile(
      URL(fileURLWithPath: filePath),
      
      completion: { fileUrl in
        self.notify(fileUrl)
        
        self.config.setValue(fileUrl, forKey: "lastUrl")
        
        if (self.config.bool(forKey: "shallOpenInBrowser")) {
          self.openInBrowser(fileUrl)
        }
        
        if (self.config.bool(forKey: "shallCopyToClipboard")) {
          self.copyUrlToClipboard(fileUrl)
        }
      }
    )
  }
  
  func openInBrowser(_ url: String) {
    NSWorkspace.shared().open(URL(string: url)!)
  }
  
  @IBAction func takeScreenshot(_ sender: AnyObject) {
    let task = Process.launchedProcess(
      launchPath: "/usr/sbin/screencapture",
      arguments: ["-C", "-W", tempFileName]
    )
    
    task.waitUntilExit()
    
    if (task.terminationStatus != 0) {
      return
    }

    uploadFile(tempFileName)
  }
  
  @IBAction func testConnection(_ sender: AnyObject) {
    api.testConnection { isValid in
      let alert = NSAlert()
      alert.messageText = "Info"
      alert.informativeText = isValid ? "Okay!" : "Error! Please check credentials."
      alert.runModal();
    }
  }
  
  
  @IBAction func openInBrowserHandler(_ sender: AnyObject) {
    if let fileUrl = self.config.string(forKey: "lastUrl") {
      self.openInBrowser(fileUrl)
    }
  }

  @IBAction func showPreferences(_ sender: AnyObject) {
    prefWindow.makeKeyAndOrderFront(self)
    NSApp.activate(ignoringOtherApps: true)
  }
}
