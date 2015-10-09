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
    
    let pedometerManager = CMManager.defaultManager
    let healthManager = HKManager.defaultManager
    
    
    @IBOutlet var stepLabel: WKInterfaceLabel!
    @IBOutlet var distanceLabel : WKInterfaceLabel!
    @IBOutlet var calorieLabel : WKInterfaceLabel!
    
    var steps : Int = 0 {
        didSet {
            currentUser.currentSteps = steps
            updateProgress()
        }
    }
    
    
    var distance : Double = 0.0 {
        didSet {
            currentUser.currentDistance = distance
            updateProgress()
        }
    }
    
    var calories : Double = 0.0 {
        didSet {
            currentUser.currentCalories = calories
            updateProgress()
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

    
    private func loadData() {
        loadStepData()
        
        if healthManager.isAuthorized {
            loadCalorieData()
        } else {
            healthManager.authorizeHealthKit({ (success, error) -> Void in
                if success {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.loadCalorieData()
                    })
                    
                }
            })
        }
     
    }
    
    private func loadStepData() {
        
        pedometerManager.dailyPedometerData { (success, result) -> Void in
            if success {
                if let data = result as? CMPedometerData {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.steps = data.numberOfSteps.integerValue
                        if let distance = data.distance?.doubleValue {
                            self.distance = distance
                        }
                        self.broadcast()
                      
                    })
                }
            }
        }
        
    }
    
    private func loadCalorieData() {
        healthManager.activeEnergyBurned { (success, result) -> Void in
            if success {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let calories = result as? Double {
                        self.calories = calories
                        self.broadcast()
                    }
                })
            }
        }
    }
    
    
    private func updateProgress() {
        
        print("update progress on watch, steps: \(currentUser.currentSteps)")
        
        let totalSteps = NSNumber(integer: currentUser.currentSteps).commaDelimitedString()
        let totalDistance = NSString(format: "%0.1f", currentUser.currentDistance * 0.00062137)
        let totalCalories = NSString(format: "%0.1f", currentUser.currentCalories / 1000)
        
        stepLabel.setText(totalSteps as String)
        distanceLabel.setText(totalDistance as String)
        calorieLabel.setText(totalCalories as String)
        
    }
    
    private func startSession() {
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
            session?.delegate = self
            session?.activateSession()
        }
    }
    
    func broadcast() {
        if let session = session where session.reachable {
            session.sendMessage(["steps": self.steps, "distance": self.distance, "calories": self.calories, "lastUpdate": NSDate()], replyHandler: nil, errorHandler: { (error) -> Void in
                print("Error sending broadcast from watch app: \(error)")
            })
        }
    }

}

extension InterfaceController : WCSessionDelegate {
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        if let lastUpdate = message["lastUpdate"] as? NSDate {
            if lastUpdate.compare(currentUser.lastUpdate!) == NSComparisonResult.OrderedDescending {
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
        }
        
    }
}