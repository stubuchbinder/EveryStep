//
//  NSNumber+EveryStep.swift
//  EveryStep
//
//  Created by Stuart Buchbinder on 9/23/15.
//  Copyright © 2015 nakkotech. All rights reserved.
//

import Foundation

extension NSNumber {
    
    func commaDelimitedString() -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        return formatter.stringFromNumber(self)!
    }
}
