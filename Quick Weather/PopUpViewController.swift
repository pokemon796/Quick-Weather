//
//  PopUpViewController.swift
//  Quick Weather
//
//  Created by Ozan Mirza on 1/21/19.
//  Copyright © 2019 Ozan Mirza. All rights reserved.
//

import Cocoa
import WebKit

class PopUpViewController: NSViewController, WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var mainView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        mainView.uiDelegate = self
        mainView.navigationDelegate = self
        
        let urlpath = Bundle.main.path(forResource: "index", ofType: "html");
        let requesturl = URL(string: urlpath!)
        let request = URLRequest(url: requesturl!)
        mainView.load(request)
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
            fatalError("Why cant i find PopUpViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}
