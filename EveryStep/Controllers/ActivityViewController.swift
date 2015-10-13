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
    
    let healthKitManager = HKManager.defaultManager
    
    var session : WCSession?
    
    var steps = 0 {
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startSession()
        
        // reload any data when the app returns from the background
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (note : NSNotification) -> Void in
            self.loadData()
        }
    }
    
    
    /**
        Refresh UI for any changes that may have happened on the settings screen
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateProgress()
    }
    
    /**
        Start watch connectivity session so that we can hand off / receive any updates to & from the watch app
    */
    private func startSession() {
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
            session?.delegate = self
            session?.activateSession()
        }
    }
    
    /**
        Send a message payload to the watch app so that data can remain in sync
    */
    private func broadcast() {
        if let session = session where session.reachable {
            session.sendMessage(["steps": steps, "calories": calories, "distance": distance, "lastUpdate" : NSDate()], replyHandler: nil, errorHandler: { (error) -> Void in
                print(error)
            })
        }
        
    }
    
    /**
        Helper method to return the start of the current day (12am)
    */
    private func midnightOfToday() -> NSDate {
        
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        
        let startDate : NSDate = calendar.startOfDayForDate(now)
        return startDate
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


    func loadStepCount() {
        healthKitManager.stepCount { (success, result) -> Void in
            if success {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.steps = result as! Int
                })
                
            }
        }
    }
    
    func loadDistance() {
        healthKitManager.distance { (success, result) -> Void in
            if success {
                
                let miles = result as! Double
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.distance = miles
                })
            }
        }
    }
    /**
        Runs a health kit statistics query for active energy burned
    */
    func loadCalories() {
        healthKitManager.activeEnergyBurned { (success, result) -> Void in
            if success == true {
                let caloriesBurned = result as? Double
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.calories = caloriesBurned!
                })
            }
        }
    }
    
    /**
        Refreshes the UI based on the data in 'currentUser'
    */
    func updateProgress() {
        // make sure UI updates happen on the main thread
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let steps = NSNumber(integer: self.currentUser.currentSteps)
            let distance = self.currentUser.currentDistance
            let goal = NSNumber(integer: self.currentUser.currentGoal)
            let calories = self.currentUser.currentCalories
            
            // step count
            self.stepCountLabel.text = steps.commaDelimitedString()
            
            // progress
            let progress = Float(steps.doubleValue / goal.doubleValue)
            self.progressView.progress = progress
            
            // update the current goal
            self.goalButton.setTitle("Goal - \(goal.commaDelimitedString())", forState: .Normal)
            
            // Distance
            let miles = distance * 0.00062137
            let mileString = NSString(format: "%0.1f", miles)
            self.distanceLabel.text = "\(mileString) mi"
            
            self.calorieLabel.hidden = (calories == 0.0)
            // Calories
            let calorieString = NSString(format: "%1.0f", (calories / 1000))
            self.calorieLabel.text = "\(calorieString) cal"
        }
      
        
    }

    /**
        User pressed the goal button.
    
        Display a text field alert so that the user can update their goal
    */
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

            })
        }
    
    }
    
    
}
