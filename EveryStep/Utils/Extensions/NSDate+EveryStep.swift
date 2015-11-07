//
//  NSDate+EveryStep.swift
//  EveryStep
//
//  Created by Stuart Buchbinder on 11/7/15.
//  Copyright © 2015 nakkotech. All rights reserved.
//

import Foundation


extension NSDate {
    
    /**
        Returns 12:00 am of today's date
    */
    class func startOfDay() -> NSDate {
        let cal = NSCalendar.currentCalendar()
        
        let comps = cal.components([NSCalendarUnit.Year, NSCalendarUnit.Month ,NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Second], fromDate: NSDate())
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        let timeZone = NSTimeZone.systemTimeZone()
        cal.timeZone = timeZone
        return cal.dateFromComponents(comps)!

    }
}