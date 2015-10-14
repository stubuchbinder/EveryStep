//
//  InterfaceController.swift
//  watchapp Extension
//
//  Created by Stuart Buchbinder on 9/30/15.
//  Copyright © 2015 nakkotech. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import CoreMotion


class InterfaceController: WKInterfaceController {

    let currentUser = ESUserController.defaultController.currentUser()
    let healthKitManager = HKManager.defaultManager
    
    @IBOutlet var stepLabel: WKInterfaceLabel!
    @IBOutlet var distanceLabel : WKInterfaceLabel!
    @IBOutlet var calorieLabel : WKInterfaceLabel!
    
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
    
    var session : WCSession?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        startSession()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        loadData()
    }


    func loadData() {
        
        if healthKitManager.isAuthorized {
            
            // Steps
            healthKitManager.stepCount { (success, result) -> Void in
                if success {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.steps = result as! Int
                    })
                    
                }
                
                // Distance
                self.healthKitManager.distance { (success, result) -> Void in
                    if success {
                        
                        let miles = result as! Double
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.distance = miles
                        })
                    }
                    
                    // Calories
                    self.healthKitManager.activeEnergyBurned { (success, result) -> Void in
                        if success == true {
                            let caloriesBurned = result as? Double
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.calories = caloriesBurned!
                            })
                        }
                        
                        self.updateProgress()
                        self.broadcast()
                    }
                }
            }
        } else {
            healthKitManager.authorizeHealthKit({ (success, error) -> Void in
                if success {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.loadData()
                    })
                }
            })
        }
    }

    
    
    private func updateProgress() {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let totalSteps = NSNumber(integer: self.currentUser.currentSteps).commaDelimitedString()
            let totalDistance = NSString(format: "%0.1f", self.currentUser.currentDistance * 0.00062137)
            let totalCalories = NSString(format: "%0.1f", self.currentUser.currentCalories / 1000)
            
            self.stepLabel.setText(totalSteps as String)
            self.distanceLabel.setText(totalDistance as String)
            self.calorieLabel.setText(totalCalories as String)
        }
    
    }
    
    private func startSession() {
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
            session?.delegate = self
            session?.activateSession()
        }
    }
    
    func broadcast() {
//        if let session = session where session.reachable {
//            session.sendMessage(["steps": self.steps, "distance": self.distance, "calories": self.calories, "lastUpdate": NSDate()], replyHandler: nil, errorHandler: { (error) -> Void in
//                print("Error sending broadcast from watch app: \(error)")
//            })
//        }
    }

}

extension InterfaceController : WCSessionDelegate {
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        
        if let lastUpdate = message["lastUpdate"] as? NSDate {
    
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if lastUpdate.compare(self.currentUser.lastUpdate) == NSComparisonResult.OrderedDescending {
                    if let steps = message["steps"] as? Int {
                        self.steps = steps
                    }
                    
                    if let distance = message["distance"] as? Double {
                        self.distance = distance
                    }
                    
                    if let calories = message["calories"] as? Double {
                        self.calories = calories
                    }
                }
                self.updateProgress()
                
            })
        }
        
    }}