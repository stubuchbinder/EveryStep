//
//  ActivityViewController.swift
//  EveryStep
//
//  Created by Stuart Buchbinder on 8/27/15.
//  Copyright © 2015 nakkotech. All rights reserved.
//

import UIKit
import CoreMotion

class ActivityViewController: UIViewController {

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var stepCountLabel: UILabel!
    @IBOutlet weak var goalButton: GoalButton!
    @IBOutlet weak var progressView: ProgressView!
   
    let currentUser = ESUserController.defaultController.currentUser()
    let pedometer = CMPedometer()
    let healthKitManager = HKManager.defaultManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (note : NSNotification) -> Void in
            self.loadData()
        }
    }
    
    func midnightOfToday() -> NSDate {
        
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        
        let startDate : NSDate = calendar.startOfDayForDate(now)
        return startDate
    }
    
    
    func loadData() {
        
        if CMPedometer.isStepCountingAvailable() && CMPedometer.isDistanceAvailable() {
            
            pedometer.queryPedometerDataFromDate(midnightOfToday(), toDate: NSDate(), withHandler: { (data: CMPedometerData?, error : NSError?) -> Void in
                if let err = error {
                    print("Error: \(err)")
                    return
                }
                
                if let steps = data?.numberOfSteps {
                    
                    self.currentUser.currentSteps = steps
                }
                
                if let distance = data?.distance {
                    self.currentUser.currentDistance = distance
                }
 
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.updateProgress()
                    (UIApplication.sharedApplication().delegate as! AppDelegate).sheduleIdleTimerNotification()
                })

            })
        }
        
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
                self.currentUser.currentCalories = caloriesBurned
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.updateProgress()
            })
        }
        
    }
    
    
    func updateProgress() {
        
        let steps = currentUser.currentSteps
        let distance = currentUser.currentDistance
        let goal = currentUser.currentGoal
        let calories = currentUser.currentCalories
        
        // step count
        self.stepCountLabel.text = steps.commaDelimitedString()
        
        // progress
        let progress = Float(steps.doubleValue / goal.doubleValue)
        progressView.progress = progress
        
        // update the current goal
        goalButton.setTitle("Goal - \(goal.commaDelimitedString())", forState: .Normal)
        
        // Distance
        let miles = distance.doubleValue * 0.00062137
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
            
            self.currentUser.currentGoal = NSNumber(int: goal.intValue)
            
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
