//
//  PopUpViewController.swift
//  Quick Weather
//
//  Created by Ozan Mirza on 1/21/19.
//  Copyright © 2019 Ozan Mirza. All rights reserved.
//
//  MAKE NOTIFICATIONS AVAILABLE
//

import Cocoa
import WebKit
import CoreLocation

class PopUpViewController: NSViewController, WKUIDelegate, WKNavigationDelegate, CLLocationManagerDelegate, NSSwitchDelegate, NSTextFieldDelegate {
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    var lat = Double()
    var lon = Double()
    
    @IBOutlet weak var mainView: WKWebView!
    @IBOutlet weak var exitBtn: NSButton!
    @IBOutlet weak var main_icon: NSImageView!
    @IBOutlet weak var notifyLbl: NSTextField!
    @IBOutlet weak var main_switch: NSSwitch!
    @IBOutlet weak var refresBtn: NSButton!
    
    let setTimerBG = NSView()
    let setter = NSButton()
    
    var time : [String] = [String(), String(), String(), String()]
    var timeFields : [NSTextField] = [NSTextField(), NSTextField(), NSTextField(), NSTextField()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // https://rawcdn.githack.com/ozanmirza1/Quick-Weather/bebecca25a472bbcdb407b88b49a0276197c6f20/Quick%20Weather/index.html
        
        self.main_switch.alphaValue = 0.0
        self.main_switch.delegate = self
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 5.0
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.locationManager.requestLocation() // Front use
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lat = locations[0].coordinate.latitude
        lon = locations[0].coordinate.longitude
        
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = 1.0
        self.main_icon.animator().alphaValue = 0
        NSAnimationContext.endGrouping()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            self.mainView.uiDelegate = self
            self.mainView.navigationDelegate = self
            self.mainView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
            self.mainView.load(URLRequest(url: URL(string: "https://rawcdn.githack.com/ozanmirza1/Quick-Weather/bebecca25a472bbcdb407b88b49a0276197c6f20/Quick%20Weather/index.html")!))
            NSAnimationContext.beginGrouping()
            NSAnimationContext.current.duration = 0.5
            self.main_switch.animator().alphaValue = 1.0
            NSAnimationContext.endGrouping()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error finding location: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        mainView.evaluateJavaScript("getWeatherData(\(lat), \(lon));", completionHandler: nil)
    }
    
    @IBAction func quitApplication(_ sender: NSButton) {
        NSApplication.shared.terminate(self)
    }
    
    func switchChanged(switch: NSSwitch) {
        if self.main_switch.on == true {
            self.setTimerBG.frame = NSRect(x: (self.view.frame.size.width / 2) - 200, y: 0 - 400, width: 400, height: 400)
            self.setTimerBG.wantsLayer = true
            self.setTimerBG.layer?.cornerRadius = 20
            self.setTimerBG.layer?.backgroundColor = NSColor(red: (181 / 255), green: (164 / 255), blue: (178 / 255), alpha: 1).cgColor
            self.view.addSubview(self.setTimerBG)
            NSAnimationContext.beginGrouping()
            NSAnimationContext.current.duration = 1.0
            self.setTimerBG.animator().setFrameOrigin(NSPoint(x: (self.view.frame.size.width / 2) - 200, y: (self.view.frame.size.height / 2) - 200))
            NSAnimationContext.endGrouping()
            let exit = NSButton(frame: NSRect(x: self.setTimerBG.frame.size.width - 55, y: self.setTimerBG.frame.size.height - 55, width: 25, height: 25))
            exit.image = NSImage(named: "close_icon")
            exit.wantsLayer = true
            exit.layer?.backgroundColor = NSColor.clear.cgColor
            exit.isBordered = false
            exit.action = #selector(self.goToRemoveTimerSetter)
            self.setTimerBG.addSubview(exit)
            let timeSetterTTL = NSTextView(frame: NSRect(x: 0, y: self.setTimerBG.frame.size.height / 1.75, width: self.setTimerBG.frame.size.width, height: 100))
            timeSetterTTL.textColor = NSColor.white
            timeSetterTTL.string = "Please set the time for when you want the notifications, we update daily."
            timeSetterTTL.textStorage?.font = NSFont.systemFont(ofSize: 25)
            timeSetterTTL.alignment = NSTextAlignment.center
            timeSetterTTL.drawsBackground = false
            self.setTimerBG.addSubview(timeSetterTTL)
            let middleColon = NSTextView(frame: NSRect(x: (self.setTimerBG.frame.size.height / 2) - 25, y: (self.setTimerBG.frame.size.height / 2) - 75, width: 50, height: 75))
            middleColon.string = ":"
            middleColon.textColor = NSColor.white
            middleColon.textStorage?.font = NSFont.systemFont(ofSize: 60)
            middleColon.drawsBackground = false
            middleColon.isEditable = false
            middleColon.alignment = NSTextAlignment.center
            self.setTimerBG.addSubview(middleColon)
            for i in 0..<self.timeFields.count {
                
                let widthSize : CGFloat = 75
                let heightSize : CGFloat = 75
                
                let distance : CGFloat = 10
                let startingPointX : CGFloat = ((self.setTimerBG.frame.size.width / 2) - (distance * 2.5)) - (widthSize * 2)
                let startingPointY : CGFloat = ((self.setTimerBG.frame.size.height / 2) - (distance / 2)) - heightSize
                
                var x_pos : CGFloat = (startingPointX + (widthSize * CGFloat(i))) + (distance * CGFloat(i))
                if i > 1 {
                    x_pos += distance * 2
                }
                let y_pos : CGFloat = startingPointY
                
                let currentLbl = NSTextField(frame: NSRect(x: x_pos, y: y_pos, width: widthSize, height: heightSize))
                currentLbl.isBezeled = false
                currentLbl.isBordered = false
                currentLbl.isHighlighted = false
                currentLbl.wantsLayer = true
                currentLbl.layer?.cornerRadius = 15
                currentLbl.layer?.masksToBounds = true
                currentLbl.delegate = self
                currentLbl.layer?.backgroundColor = NSColor.white.cgColor
                currentLbl.drawsBackground = false
                currentLbl.textColor = NSColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 1)
                currentLbl.alignment = NSTextAlignment.center
                currentLbl.font = NSFont.systemFont(ofSize: 50)
                currentLbl.delegate = self
                
                self.setTimerBG.addSubview(currentLbl)
                self.timeFields[i] = currentLbl
            }
        } else {
            self.removeTimerSetter()
            NSUserNotificationCenter.default.removeScheduledNotification(NSUserNotificationCenter.default.scheduledNotifications[0])
        }
    }
    
    func controlTextDidChange(_ obj: Notification) {
        for i in 0..<timeFields.count {
            let currentTextField = obj.object as? NSTextField
            if timeFields[i] == currentTextField {
                if (currentTextField?.stringValue.containsInteger())! == false {
                    currentTextField?.layer?.backgroundColor = NSColor(red: (244 / 255), green: (66 / 255), blue: (66 / 255), alpha: 1).cgColor
                    currentTextField?.stringValue = ""
                    let warning = NSTextView(frame: NSRect(x: 0, y: setTimerBG.frame.size.height / 8, width: setTimerBG.frame.size.width, height: 50))
                    warning.string = "Make sure that each box contains one number ranging from 0 - 9"
                    warning.drawsBackground = false
                    warning.textStorage?.font = NSFont.systemFont(ofSize: 20)
                    warning.textColor = NSColor.white
                    warning.alignment = NSTextAlignment.center
                    setTimerBG.addSubview(warning)
                } else {
                    currentTextField?.layer?.backgroundColor = NSColor.white.cgColor
                    time[i] = (currentTextField?.stringValue)!
                    if i == timeFields.count - 1{
                        setter.frame = NSRect(x: setTimerBG.frame.origin.x, y: 0, width: setTimerBG.frame.size.width, height: 35)
                        setter.isBordered = false
                        setter.wantsLayer = true
                        setter.layer?.cornerRadius = setter.frame.size.height / 2
                        setter.layer?.masksToBounds = true
                        setter.layer?.backgroundColor = NSColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 1).cgColor
                        setter.title = "Done"
                        setter.contentTintColor = NSColor.white
                        setter.font = NSFont.systemFont(ofSize: 25)
                        setter.action = #selector(self.activateNotifications(_:))
                        self.view.addSubview(setter)
                        NSAnimationContext.beginGrouping()
                        NSAnimationContext.current.duration = 1.0
                        setter.animator().setFrameOrigin(NSPoint(x: setTimerBG.frame.origin.x, y: setTimerBG.frame.origin.y))
                        NSAnimationContext.endGrouping()
                    }
                }
            }
        }
    }
    
    @objc func activateNotifications(_ sender: NSButton!) {
        self.removeTimerSetter()
        
        let notification = NSUserNotification()
        notification.soundName = NSUserNotificationDefaultSoundName
        
        var deliveryDate = DateComponents()
        deliveryDate.hour = Int(timeFields[0].stringValue + timeFields[1].stringValue)
        deliveryDate.minute = Int(timeFields[2].stringValue + timeFields[3].stringValue)
        
        notification.deliveryDate = Calendar.current.date(from: deliveryDate)
        
        self.mainView.evaluateJavaScript("data.weather") { (result, error) in
            if error != nil {
                print("Error Finding Weather Data: " + error.debugDescription)
            } else {
                notification.title = result as? String
            }
        }
        
        self.mainView.evaluateJavaScript("data.temp") { (result, error) in
            if error != nil {
                print("Error Finding Temp Data: " + error.debugDescription)
            } else {
                notification.subtitle = "Current Temperature: " + (result as? NSNumber)!.stringValue + "F"
            }
        }
        
        self.mainView.evaluateJavaScript("data.min") { (result, error) in
            if error != nil {
                print("Error Finding Min Data: " + error.debugDescription)
            } else {
                notification.informativeText = "Min: " + (result as? NSNumber)!.stringValue + "F"
            }
        }
        
        self.mainView.evaluateJavaScript("data.max") { (result, error) in
            if error != nil {
                print("Error Finding Max Data: " + error.debugDescription)
            } else {
                notification.informativeText = notification.informativeText! + ", Max: " + (result as? NSNumber)!.stringValue + "F"
            }
        }
        
        self.mainView.evaluateJavaScript("data.icon") { (result, error) in
            if error != nil {
                print("Error Finding Weather Data: " + error.debugDescription)
            } else {
                notification.contentImage = NSImage(named: (result as? String)!)
            }
        }
        
        NSUserNotificationCenter.default.scheduleNotification(notification)
    }
    
    @objc func goToRemoveTimerSetter() {
        self.removeTimerSetter()
        self.main_switch.setOn(on: false, animated: true)
    }
    
    func removeTimerSetter() {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = 1.0
        setTimerBG.animator().setFrameOrigin(NSPoint(x: setTimerBG.frame.origin.x, y: 0 - setTimerBG.frame.size.height))
        setter.animator().setFrameOrigin(NSPoint(x: setter.frame.origin.x, y: 0 - 100))
        NSAnimationContext.endGrouping()
    }
    
    @IBAction func refreshWeatherContent(_ sender: NSButton) {
        mainView.load(URLRequest(url: URL(string: "https://rawcdn.githack.com/ozanmirza1/Quick-Weather/bebecca25a472bbcdb407b88b49a0276197c6f20/Quick%20Weather/index.html")!))
    }
    
    func convertToSeconds(hours: Int, minutes: Int) -> Double {
        var finalTime = 0
        finalTime += (hours * 24) * 60
        finalTime += minutes * 60
        
        return Double(finalTime)
    }
}

extension PopUpViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> PopUpViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name(stringLiteral: "Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier(stringLiteral: "PopUpViewController")
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? PopUpViewController else {
            fatalError("Error: PopUp View Controller Not Found")
        }
        return viewcontroller
    }
}
