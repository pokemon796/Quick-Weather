//
//  PopUpViewController.swift
//  Quick Weather
//
//  Created by Ozan Mirza on 1/21/19.
//  Copyright © 2019 Ozan Mirza. All rights reserved.
//

import Cocoa
import WebKit
import CoreLocation

class PopUpViewController: NSViewController, WKUIDelegate, WKNavigationDelegate, CLLocationManagerDelegate, NSTextFieldDelegate {
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    var lat = Double()
    var lon = Double()
    
    @IBOutlet weak var mainView: WKWebView!
    @IBOutlet weak var exitBtn: NSButton!
    @IBOutlet weak var main_icon: NSImageView!
    @IBOutlet weak var refresBtn: NSButton!
    
    let setTimerBG = NSView()
    let setter = NSButton()
    
    var time : [String] = [String(), String(), String(), String()]
    var timeFields : [NSTextField] = [NSTextField(), NSTextField(), NSTextField(), NSTextField()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // https://rawcdn.githack.com/ozanmirza1/Quick-Weather/bebecca25a472bbcdb407b88b49a0276197c6f20/Quick%20Weather/index.html
        
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
