//
//  CMPedometerManager.swift
//  EveryStep
//
//  Created by Stuart Buchbinder on 11/7/15.
//  Copyright © 2015 nakkotech. All rights reserved.
//

import UIKit
import CoreMotion

class CMPedometerManager: NSObject {
    
    private let pedometer : CMPedometer = CMPedometer()
    
    class var defaultManager : CMPedometerManager {
        
        struct Singleton {
            static let instance = CMPedometerManager()
        }
        
        return Singleton.instance
    }
    
    private override init() {
        super.init()
    }
    
    class func isStepCountingAvailable() -> Bool {
        return CMPedometer.isStepCountingAvailable()
    }
    
    class  func isDistanceAvailable() -> Bool {
        return CMPedometer.isDistanceAvailable()
    }
    
    func currentPedometerData(completion : (success : Bool, result : AnyObject?) -> Void) {
        pedometer.queryPedometerDataFromDate(NSDate.startOfDay(), toDate: NSDate()) { (data: CMPedometerData?, error : NSError?) -> Void in
            if let _ = error {
                print("Error getting current step count: \(error)")
                completion(success: false, result: error)
                return
            }
            
            if let _ = data {
                completion(success: true, result: data)
            } else {
                completion(success: false, result: nil)
            }
            
        }
    }
    
}
