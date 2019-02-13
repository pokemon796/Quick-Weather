//
//  NSTextFieldExtension.swift
//  Quick Weather-MAC
//
//  Created by Ozan Mirza on 2/9/19.
//  Copyright © 2019 Ozan Mirza. All rights reserved.
//

import Cocoa

extension String {
    func containsInteger() -> Bool {
        for i in 0...9 {
            if self == String(i) {
                return true
            }
        }
        
        return false
    }
}
