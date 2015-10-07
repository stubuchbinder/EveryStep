//
//  HKManager.swift
//  EveryStep
//
//  Created by Stuart Buchbinder on 9/24/15.
//  Copyright © 2015 nakkotech. All rights reserved.
//

import Foundation
import HealthKit

class HKManager : NSObject {
    
    let healthStore = HKHealthStore()
    var isAuthorized = false
    
    class var defaultManager : HKManager {
        
        struct Singleton {
            static let instance = HKManager()
        }
        
        return Singleton.instance
    }
    
    
    private override init() {
        super.init()
        
    }
    func authorizeHealthKit(completion : (success : Bool, error : NSError?) -> Void) {
        
        if HKHealthStore.isHealthDataAvailable() == false {
            let error = NSError(domain: "com.nakkotech.EveryStep", code: 2, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"])
            completion(success: false, error: error)
            return
        }
        
        let calorieType : HKQuantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!
        
        healthStore.requestAuthorizationToShareTypes(nil, readTypes: NSSet(objects: calorieType) as? Set<HKObjectType> ) { (success completed: Bool, error err: NSError?) -> Void in
            if err != nil {
                completion(success: false, error: err!)
            } else {
                self.isAuthorized = true
                completion(success: true, error: nil)
            }
        }
    }
    
    private func predicateSamplesForToday() -> NSPredicate {
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        
        let startDate : NSDate = calendar.startOfDayForDate(now)
        let endDate : NSDate = calendar.dateByAddingUnit(NSCalendarUnit.Day, value: 1, toDate: startDate, options: NSCalendarOptions())!
        
        return HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: HKQueryOptions.StrictStartDate)
    }
    
    
    func activeEnergyBurned(completion: (success : Bool, result : AnyObject?) -> Void) {
        let activeEnergyBurnType : HKQuantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!
        
        let predicate = predicateSamplesForToday()
        
        let query = HKStatisticsQuery(quantityType: activeEnergyBurnType, quantitySamplePredicate: predicate, options: HKStatisticsOptions.CumulativeSum) { (query : HKStatisticsQuery, result : HKStatistics?, error : NSError?) -> Void in
            
            if let quantity = result?.sumQuantity() {
                let value = quantity.doubleValueForUnit(HKUnit.calorieUnit())
                completion(success: true, result: value)
            } else {
                completion(success: false, result: NSError(domain: "com.nakkotech.everystep", code: 2, userInfo: [NSLocalizedDescriptionKey: "0 calories returned"]))
            }
            
        }
        
        healthStore.executeQuery(query)
    }
}
