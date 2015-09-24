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
    
//    var totalSteps : NSNumber {
//        set {
//            currentUser.currentSteps = totalSteps
//        } get {
//            return currentUser.currentSteps
//        }
//    }
//    
//    var totalDistance : NSNumber {
//        set {
//            currentUser.currentDistance = totalSteps
//        } get {
//            return currentUser.currentDistance
//        }
//    }
//    
    let currentUser = ESUserController.defaultController.currentUser()
    let pedometer = CMPedometer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (note : NSNotification) -> Void in
            self.loadData()
        }

    
    }
    
    func midnightOfToday() -> NSDate {
        let cal = NSCalendar.currentCalendar()
  
        let comps = cal.components([NSCalendarUnit.Year, NSCalendarUnit.Month ,NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Second], fromDate: NSDate())
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        let timeZone = NSTimeZone.systemTimeZone()
        cal.timeZone = timeZone
        return cal.dateFromComponents(comps)!
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
                })

            })

        }
    }
    func updateProgress() {
        
        let steps = currentUser.currentSteps
        let distance = currentUser.currentDistance
        let goal = currentUser.currentGoal
        
        // step count
        self.stepCountLabel.text = steps.commaDelimitedString()
        
        // progress
        let progress = Float(steps.doubleValue / goal.doubleValue)
        progressView.progress = progress
        
        // update the current goal
        goalButton.setTitle("Goal - \(goal.commaDelimitedString())", forState: .Normal)
        
        let miles = distance.doubleValue * 0.00062137
        let mileString = NSString(format: "%0.1f", miles)
        distanceLabel.text = "\(mileString) mi"
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
