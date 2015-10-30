//
//  ExtensionDelegate.swift
//  watchapp Extension
//
//  Created by Stuart Buchbinder on 9/30/15.
//  Copyright © 2015 nakkotech. All rights reserved.
//

import WatchKit

public enum Notification : String {
    case Activity = "activity_notification"
}

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    let currentUser = ESUserController.defaultController.currentUser()
    
    var steps : Int = 0 {
        didSet {
            currentUser.currentSteps = steps
        }
    }
    
    
    var distance : Double = 0.0 {
        didSet {
            currentUser.currentDistance = distance
        }
    }
    
    var calories : Double = 0.0 {
        didSet {
            currentUser.currentCalories = calories
        }
    }

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        loadData()
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    
    /**
        Sync HealthKit data and update the User model.
     
        If HK has not been authorized, request authorization and retry load upon completion.
    */
    func loadData() {
        
        let manager = HKManager.defaultManager
        
        if manager.isAuthorized {
            
            manager.stepCount({ (success, result) -> Void in
                if success {
                    self.steps = result as! Int
                } else {
                    self.steps = 0
                    print("Error getting step count: \((result as! NSError).localizedDescription)")
                }
                
                manager.distance({ (success, result) -> Void in
                    if success {
                        self.distance = result as! Double
                    } else {
                        self.distance = 0.0
                        print("Error getting distance: \((result as! NSError).localizedDescription)")
                    }
                    
                    manager.activeEnergyBurned({ (success, result) -> Void in
                        if success == true {
                            self.calories = result as! Double
                        } else {
                            self.calories = 0.0
                            print("Error getting distance: \((result as! NSError).localizedDescription)")
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            NSNotificationCenter.defaultCenter().postNotificationName(Notification.Activity.rawValue, object: nil)
                        })
                        
                    })
                })
            })
            
        } else {
            manager.authorizeHealthKit({ (success, error) -> Void in
                if success {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.loadData()
                    })
                }
              
            })
        }
        
    }

}
