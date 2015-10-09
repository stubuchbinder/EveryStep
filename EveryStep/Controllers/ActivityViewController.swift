//
//  ActivityViewController.swift
//  EveryStep
//
//  Created by Stuart Buchbinder on 8/27/15.
//  Copyright © 2015 nakkotech. All rights reserved.
//

import UIKit
import CoreMotion
import WatchConnectivity

class ActivityViewController: UIViewController {

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var stepCountLabel: UILabel!
    @IBOutlet weak var goalButton: GoalButton!
    @IBOutlet weak var progressView: ProgressView!
   
    let currentUser = ESUserController.defaultController.currentUser()
    
    let pedometerManager = CMManager.defaultManager
    let healthKitManager = HKManager.defaultManager
    
    var session : WCSession?
    
    var steps = 0 {
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startSession()
        
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (note : NSNotification) -> Void in
            self.loadData()
        }
        
        
    }
    
    private func startSession() {
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
            session?.delegate = self
            session?.activateSession()
        }
    }
    
    
    private func broadcast() {
        if let session = session where session.reachable {
            session.sendMessage(["steps": steps, "calories": calories, "distance": distance, "lastUpdate" : NSDate()], replyHandler: nil, errorHandler: { (error) -> Void in
                print(error)
            })
        }
        
    }
    
    
    func midnightOfToday() -> NSDate {
        
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        
        let startDate : NSDate = calendar.startOfDayForDate(now)
        return startDate
    }
    
    
    func loadData() {
        
        // Load step count and distance if it's available
        if pedometerManager.isStepCountingAvailable() {
            
            pedometerManager.dailyPedometerData({ (success, result) -> Void in
                if success {
                    
                    if let data = result as? CMPedometerData {
                        
                        self.steps = data.numberOfSteps.integerValue
                        self.distance = data.distance! as Double
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.updateProgress()
                            self.broadcast()
                            (UIApplication.sharedApplication().delegate as! AppDelegate).sheduleIdleTimerNotification()

                        })
                        
                    }
                } else {
                    // Alert Error
                }
            })
        } else {
            // Alert that step counting is not available on this device
            
        }
        
        // Load calorie burn
        
        if healthKitManager.isAuthorized {
            loadCalories()
        } else {
            healthKitManager.authorizeHealthKit({ (success, error) -> Void in
                if success {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.loadCalories()
                    })
                }
            })
        }
    
    }


    func loadCalories() {
        
        healthKitManager.activeEnergyBurned { (success, result) -> Void in
            if success == true {
                let caloriesBurned = result as? Double
                self.calories = caloriesBurned!
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.updateProgress()
                self.broadcast()
            })
        }
        
    }
    
    
    func updateProgress() {
        
        let steps = NSNumber(integer: currentUser.currentSteps)
        let distance = currentUser.currentDistance
        let goal = NSNumber(integer: currentUser.currentGoal)
        let calories = currentUser.currentCalories
        
        // step count
        self.stepCountLabel.text = steps.commaDelimitedString()
        
        // progress
        let progress = Float(steps.doubleValue / goal.doubleValue)
        progressView.progress = progress
        
        // update the current goal
        goalButton.setTitle("Goal - \(goal.commaDelimitedString())", forState: .Normal)
        
        // Distance
        let miles = distance * 0.00062137
        let mileString = NSString(format: "%0.1f", miles)
        distanceLabel.text = "\(mileString) mi"
        
        calorieLabel.hidden = (calories == 0.0)
        // Calories
        let calorieString = NSString(format: "%1.0f", (calories / 1000))
        calorieLabel.text = "\(calorieString) cal"
        
    }

    /**
        User pressed the goal button
    **/
    @IBAction func pressedGoalButton(sender: AnyObject) {
        
        let alertController = UIAlertController(title: "New Goal", message: "Set a new daily step goal", preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action) -> Void in
            let textField = alertController.textFields![0] 
            
            if textField.text!.isEmpty { return }
            
            let goal = textField.text! as NSString
            
            self.currentUser.currentGoal = goal.integerValue
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.updateProgress()
            })
            
        }
        
        alertController.addAction(saveAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.keyboardType = .NumberPad
        }
        
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }

}

extension ActivityViewController : WCSessionDelegate {
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
