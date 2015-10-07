//
//  CMManager.swift
//  EveryStep
//
//  Created by Stuart Buchbinder on 10/7/15.
//  Copyright © 2015 nakkotech. All rights reserved.
//

import UIKit
import CoreMotion

class CMManager: NSObject {
    
    let pedometer = CMPedometer()
    
    class var defaultManager : CMManager {
        
        struct Singleton {
            static let instance = CMManager()
        }
        
        return Singleton.instance
    }
    
    private override init() {
        super.init()
    }
    
    // MARK: - Helpers
    
    
    func midnightOfToday() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        
        let startDate : NSDate = calendar.startOfDayForDate(now)
        return startDate
    }
    
    func isStepCountingAvailable()->Bool {
        return CMPedometer.isStepCountingAvailable()
    }
    
    func dailyPedometerData(completion:(success : Bool, result : AnyObject?) -> Void) {
        if isStepCountingAvailable() {
            pedometer.queryPedometerDataFromDate(midnightOfToday(), toDate: NSDate(), withHandler: { (data: CMPedometerData?, error: NSError?) -> Void in
                
                completion(success: true, result: data!)
                
            })
        } else {
            let error = NSError(domain: "com.nakkotech.everystep.error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Step counting is not enabled on this device."])
            completion(success: false, result: error)
        }
    }

}
