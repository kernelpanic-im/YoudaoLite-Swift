//
//  AppDelegate.swift
//  YoudaoLite-Swift
//
//  Created by hewig on 6/4/14.
//  Copyright (c) 2014 hewig. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
                            
    @IBOutlet var window: NSWindow
    @IBOutlet var queryField:NSTextField;
    
    let kYoudaoKeyFrom = "kernelpanic"
    let kYoudaoKey = "482091942"
    
    var networkQueue:NSOperationQueue!
    var attachWindow:MAAttachedWindow?

    override func awakeFromNib(){
        var button:NSButton? = self.window.standardWindowButton(.ZoomButton)
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        self.networkQueue = NSOperationQueue()
        self.networkQueue.name = "networkQueue"
        self.networkQueue.maxConcurrentOperationCount = 10
    }
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldHandleReopen(sender: NSApplication!, hasVisibleWindows flag: Bool) -> Bool{
        self.window.makeKeyAndOrderFront(self)
        return true
    }
    
    func queryYoudao(query:String){
        let encodedString = query.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let requestString = "http://fanyi.youdao.com/openapi.do?keyfrom=\(kYoudaoKeyFrom)&key=\(kYoudaoKey)&type=data&doctype=json&version=1.1&q=\(encodedString)"
        
        let request = NSURLRequest(URL: NSURL(string: requestString))
        
        NSURLConnection.sendAsynchronousRequest(request, queue: networkQueue, completionHandler:{(response, data, error) in
            if error {
                return
            }
            
            var jsonError : NSErrorPointer = nil
            let jsonOption : NSJSONReadingOptions = NSJSONReadingOptions()
            
            if let jsonDict: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options:jsonOption, error:jsonError){
                //println(jsonDict)
                var explains:NSArray? = jsonDict.valueForKeyPath("basic.explains") as? NSArray
                var webResults:NSArray? = jsonDict.valueForKey("web") as? NSArray
                var translation:NSArray? =  jsonDict.valueForKey("translation") as? NSArray
                if explains {
                    self.showQueryResult(explains!.componentsJoinedByString("\n"))
                }
                else if webResults{
                    var results:String[] = []
                    for webResult:AnyObject in webResults!{
                        let dict = webResult as? NSDictionary
                        let key:String = dict!["key"] as String
                        let array:NSArray? = dict!.valueForKey("value") as? NSArray
                        let value = array!.componentsJoinedByString(" ")
                        println(key, value)
                        results.append("\(key.utf8) : \(value)")
                    }
                    var finalString:String = ""
                    for result in results{
                        finalString = finalString + " "
                    }
                    self.showQueryResult(finalString)
                }
                else if translation{
                    self.showQueryResult(translation!.componentsJoinedByString("|"))
                }
                
            }
        })
    }
    
    func showQueryResult(result:String){
        //println(result)
        
        var buttonPoint = NSMakePoint(NSMidX(self.queryField.frame), NSMidY(self.queryField.frame))
        let frameHeight : CGFloat  = 220
        
        var view : NSView = NSView(frame:NSMakeRect(0, 0, 368, frameHeight));
        var label: NSTextField = NSTextField(frame:NSMakeRect(0, 0, 368, frameHeight));
        
        label.bezeled = false
        label.drawsBackground = false
        label.editable = false
        label.selectable = true
        label.stringValue = result
        label.font = NSFont.systemFontOfSize(14)
        label.textColor = NSColor.whiteColor()

        view.addSubview(label)
        
        self.attachWindow = MAAttachedWindow(view:view, attachedToPoint: buttonPoint, inWindow: self.queryField.window, atDistance:25)
        
        self.attachWindow!.setHasArrow(0)
        self.attachWindow!.setArrowHeight(1.0)
        self.attachWindow!.setArrowBaseWidth(1.0)
        self.queryField.window.addChildWindow(self.attachWindow, ordered: .Above)
    }
    
    @IBAction func queryEntered(sender : AnyObject) {
        if self.queryField.stringValue.isEmpty {
            return
        } else{
            //println(self.queryField.stringValue)
            self.window.title = "translate => \(self.queryField.stringValue)"
            self.queryYoudao(self.queryField.stringValue)
        }
    }
    
}

