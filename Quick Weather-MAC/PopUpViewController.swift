//
//  PopUpViewController.swift
//  Quick Weather-MAC
//
//  Created by Ozan Mirza on 2/9/19.
//  Copyright © 2019 Ozan Mirza. All rights reserved.
//

import Cocoa
import WebKit
import CoreLocation

class PopUpViewController: NSViewController, WKUIDelegate, WKNavigationDelegate, CLLocationManagerDelegate, NSTextFieldDelegate {
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    var lat = Double()
    var lon = Double()
    var locationSent = false
    var autoLocationSelected = true
    var setCity = false
    var addressString = ""
    var initLatLon = CLLocation()
    
    @IBOutlet weak var mainView: WKWebView!
    @IBOutlet weak var exitBtn: NSButton!
    @IBOutlet weak var main_icon: NSImageView!
    @IBOutlet weak var refresBtn: NSButton!
    @IBOutlet weak var statusLbl: NSTextField!
    @IBOutlet weak var locationSelector: NSButton!
    @IBOutlet weak var cityLbl: NSTextField!
    @IBOutlet weak var cityPicker: NSVisualEffectView!
    @IBOutlet weak var citySetter: NSTextField!
    @IBOutlet weak var autoViews: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Weather Content: https://rawcdn.githack.com/ozanmirza1/Quick-Weather/bebecca25a472bbcdb407b88b49a0276197c6f20/Quick%20Weather/index.html
        // City Names: https://raw.githubusercontent.com/lutangar/cities.json/master/cities.json
        
        self.citySetter.delegate = self
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        cityPicker.wantsLayer = true
        cityPicker.layer?.cornerRadius = 25
        cityPicker.layer?.masksToBounds = true
        cityPicker.frame.origin.y = 0 - cityPicker.frame.size.height
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.locationManager.requestLocation() // Front use
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lat = locations[0].coordinate.latitude
        lon = locations[0].coordinate.longitude
        initLatLon = CLLocation(latitude: lat, longitude: lon)
        
        statusLbl.textColor = NSColor(red: (66 / 255), green: (134 / 255), blue: (244 / 255), alpha: 1)
        statusLbl.stringValue = "Location Found!"
        
        if setCity == false {
            setCity = true
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: lat, longitude: lon)) { (placemarks, error) in
                if error != nil {
                    self.dialogOKCancel(question: "Uh-Oh, can't find city! :(", text: "We can still display the weather for you, but not the city name.")
                } else {
                    guard let placeMark = placemarks?.first else { return }
                    
                    if let city = placeMark.subAdministrativeArea {
                        self.cityLbl.stringValue += city
                    }
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            NSAnimationContext.beginGrouping()
            NSAnimationContext.current.duration = 1.0
            self.main_icon.animator().alphaValue = 0
            self.statusLbl.animator().alphaValue = 0
            NSAnimationContext.endGrouping()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.mainView.uiDelegate = self
                self.mainView.navigationDelegate = self
                self.mainView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
                self.mainView.load(URLRequest(url: URL(string: "https://rawcdn.githack.com/ozanmirza1/Quick-Weather/de2032bdef9163a654181336f1864b4f9ebf0181/Quick%20Weather/index.html")!))
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        statusLbl.textColor = NSColor(red: (244 / 255), green: (66 / 255), blue: (66 / 255), alpha: 1)
        statusLbl.stringValue = "Could'nt find location, please check permissions"
        
        if windowOpen == true && locationSent == false {
            dialogOKCancel(question: "Error Finding Location:", text: "Please click OK, then try again.")
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        locationSent = true
        mainView.evaluateJavaScript("getWeatherData(\(lat), \(lon));", completionHandler: nil)
    }
    
    @IBAction func quitApplication(_ sender: NSButton) {
        NSApplication.shared.terminate(self)
    }
    
    func controlTextDidChange(_ obj: Notification) {
        if (obj.object as? NSTextField)! == citySetter {
            citySetter.stringValue = citySetter.stringValue.trimmingCharacters(in: CharacterSet(charactersIn: "/\\"))
            let finder = citySetter.stringValue.replacingOccurrences(of: " ", with: "%20")
            autoCompleteCityNames(with: finder, completion: { parsedData in
                DispatchQueue.main.async {
                    self.autoViews.subviews.forEach { subLbl in subLbl.removeFromSuperview() }
                    var y_pos = self.autoViews.frame.size.height
                    if parsedData != nil {
                        for i in 0..<parsedData!.predictions.count {
                            let subLbl = NSButton(frame: NSRect(x: 0, y: y_pos, width: 375, height: 50))
                            y_pos -= 50
                            subLbl.wantsLayer = true
                            subLbl.layer?.backgroundColor = NSColor.clear.cgColor
                            subLbl.font = NSFont.systemFont(ofSize: 25)
                            subLbl.title = parsedData!.predictions[i].description!
                            subLbl.isBordered = false
                            subLbl.action = #selector(self.setCustomLocation(_:))
                            self.autoViews.addSubview(subLbl)
                            let divider = NSView(frame: NSRect(x: 0, y: y_pos, width: 375, height: 2))
                            divider.wantsLayer = true
                            divider.layer?.backgroundColor = NSColor.gray.cgColor
                            self.autoViews.addSubview(divider)
                        }
                    }
                }
            })
        }
    }
    
    @objc func setCustomLocation(_ sender: NSButton!) {
        for i in 0..<self.autoViews.subviews.count {
            if(self.autoViews.subviews[i] as? NSButton) != nil {
                (self.autoViews.subviews[i] as? NSButton)?.action = nil
            }
        }
        
        URLSession.shared.dataTask(with: URL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=" + sender.title.replacingOccurrences(of: " ", with: "%20") + "&types=address&language=en&sensor=true&key=AIzaSyA8pukmW_of-7QT_Y1FH9MkqZOq4X8Ux7o")!) { (data, response, error) in
            guard let data = data else { return }
            do {
                let address = try JSONDecoder().decode(PLaces.self, from: data)
                if address.status == "ZERO_RESULTS" {
                    self.dialogOKCancel(question: "Uh-Oh, Something Went Wrong", text: "We unfortunatly can't get the weather for that city at the moment.")
                    self.autoLocationSelected = true
                    self.autoLocationStatus(sender)
                } else {
                    CLLocationManager.getLocation(forPlaceCalled: address.predictions[0].description!) { (location) in
                        if location == nil {
                            self.dialogOKCancel(question: "Error Converting Location", text: "The Location cannot be converted in readable geocoordinates.")
                        } else {
                            self.lat = location!.coordinate.latitude
                            self.lon = location!.coordinate.longitude
                            
                            DispatchQueue.main.async {
                                self.cityLbl.stringValue = "City: " + sender.title
                                self.refreshWeatherContent(sender)
                                
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
                                    self.dismissCityPicker()
                                })
                            }
                        }
                    }
                }
            } catch let error {
                
                self.dialogOKCancel(question: "Error Parsing JSON:", text: error.localizedDescription)
            }
        }.resume()
    }
    
    @IBAction func refreshWeatherContent(_ sender: NSButton) {
        mainView.load(URLRequest(url: URL(string: "https://rawcdn.githack.com/ozanmirza1/Quick-Weather/bebecca25a472bbcdb407b88b49a0276197c6f20/Quick%20Weather/index.html")!))
    }
    
    func dialogOKCancel(question: String, text: String) {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @IBAction func autoLocationStatus(_ sender: NSButton) {
        autoLocationSelected = !autoLocationSelected
        
        if autoLocationSelected == true {
            locationSelector.image = NSImage(named: NSImage.Name("location_selected_icon"))
            locationManager.startUpdatingLocation()
            lat = initLatLon.coordinate.latitude
            lon = initLatLon.coordinate.longitude
            self.refreshWeatherContent(sender)
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: lat, longitude: lon)) { (placemarks, error) in
                if error != nil {
                    self.dialogOKCancel(question: "Uh-Oh, can't find city! :(", text: "We can still display the weather for you, but not the city name.")
                } else {
                    guard let placeMark = placemarks?.first else { return }
                    
                    if let city = placeMark.subAdministrativeArea {
                        self.cityLbl.stringValue = "City: " + city
                    }
                }
            }
        } else {
            locationSelector.image = NSImage(named: NSImage.Name("location_unselected_icon"))
            locationManager.stopUpdatingLocation()
            
            NSAnimationContext.beginGrouping()
            NSAnimationContext.current.duration = 1
            cityPicker.animator().frame.origin.y = 87.5
            NSAnimationContext.endGrouping()
        }
    }
    
    @IBAction func closeCitypicker(_ sender: NSButton) {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = 1
        cityPicker.animator().frame.origin.y = 0 - cityPicker.frame.size.height
        NSAnimationContext.endGrouping()
        self.autoLocationStatus(sender)
    }
    
    func dismissCityPicker() {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = 1
        cityPicker.animator().frame.origin.y = 0 - cityPicker.frame.size.height
        NSAnimationContext.endGrouping()
    }
    
    func autoCompleteCityNames(with contents: String, completion:@escaping (PLaces?)->()) {
        URLSession.shared.dataTask(with: URL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=" + contents + "&types=(cities)&language=en&sensor=true&key=AIzaSyA8pukmW_of-7QT_Y1FH9MkqZOq4X8Ux7o")!) { (data, response, error) in
            guard let data = data else { return }
            do {
                return completion(try JSONDecoder().decode(PLaces.self, from: data))
            } catch let error {
                self.dialogOKCancel(question: "Error Parsing JSON:", text: error.localizedDescription)
                return completion(nil)
            }
        }.resume()
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
