//
//  ESUserDefaults.swift
//  EveryStep
//
//  Created by Stuart Buchbinder on 3/2/16.
//  Copyright © 2016 nakkotech. All rights reserved.
//

import Foundation


struct UserDefaults {
    static let LaunchCount = "launch_count"
    static let RateApp = "rate_app"
}

class ESUserDefaults : NSObject {
    
    
   static let standardUserDefaults = ESUserDefaults()
  
    
     func incrementLaunchCount() {
         let defaults = NSUserDefaults()
        
        guard let currentLaunchCount = defaults.valueForKey(UserDefaults.LaunchCount) as? Int else {
            resetLaunchCount()
            return
        }
        
        let newLaunchCount = currentLaunchCount + 1
        defaults.setValue(newLaunchCount, forKey: UserDefaults.LaunchCount)
        defaults.synchronize()
    
    }
    
    func resetLaunchCount() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(1, forKey: UserDefaults.LaunchCount)
        defaults.synchronize()
    }
    
    func shouldDisplayRating() -> Bool {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        guard let _ = defaults.valueForKey(UserDefaults.RateApp) as? Bool else {
            
            guard let currentLaunchCount = defaults.valueForKey(UserDefaults.LaunchCount) as? Int else {
                return false
            }
            
            let displayAfterLaunches = 3
            
            if currentLaunchCount % displayAfterLaunches == 0 {
                return true
            }
            return false
        }
        
        return false
    }
    
    func ratedApp(value: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(value, forKey: UserDefaults.RateApp)
        defaults.synchronize()
    }
    
    func launchCount() -> Int{
        let defaults = NSUserDefaults.standardUserDefaults()
        guard let launchCount = defaults.valueForKey(UserDefaults.LaunchCount) as? Int else {
            return 0
        }
        return launchCount
    }
}