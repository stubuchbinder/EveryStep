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

    
    // MARK: - Time Formatting
    
    // Possible time formats for conversion to Hours/Minutes/Seconds
    enum TimeFormat : String {
        case Hours = "H"
        case HHours = "HH"
        case Minutes = "m"
        case MMinutes = "mm"
        case Seconds = "s"
        case SSeconds = "ss"
        
    }
    
    func timeFormattedStringWithTimeFormat(format format: TimeFormat) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        return formatter.stringFromDate(NSDate(timeIntervalSinceReferenceDate: self.doubleValue))
    }
    
    
   
}
