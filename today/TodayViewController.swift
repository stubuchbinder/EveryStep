//
//  TodayViewController.swift
//  today
//
//  Created by Stuart Buchbinder on 10/13/15.
//  Copyright © 2015 nakkotech. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var stepCountLabel: UILabel!
    
    let healthKitManager = HKManager.defaultManager
    
    let currentUser = ESUserController.defaultController.currentUser()
    
    
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
        updateContentSize()
    }
    

    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        loadData()

        completionHandler(NCUpdateResult.NewData)
    }
    
    
    
    private func updateContentSize() {
        let contentWidth = self.view.bounds.width
        let contentHeight : CGFloat = (calories == 0.0) ? 60.0 : 80.0
        self.preferredContentSize = CGSize(width: contentWidth, height: contentHeight)
    }
    
    
    func loadData() {
        
        if healthKitManager.isAuthorized {
            
            // Steps
            healthKitManager.stepCount { (success, result) -> Void in
                if success {
                    self.steps = result as! Int
                } else {
                    self.steps = 0
                    print("Error getting step count: \((result as! NSError).localizedDescription)")
                }
                
                // Distance
                self.healthKitManager.distance { (success, result) -> Void in
                    if success {
                        self.distance = result as! Double
                    } else {
                        self.distance = 0.0
                        print("Error getting distance: \((result as! NSError).localizedDescription)")
                    }
                    
                    // Calories
                    self.healthKitManager.activeEnergyBurned { (success, result) -> Void in
                        if success == true {
                            self.calories = result as! Double
                        } else {
                            self.calories = 0.0
                            print("Error getting distance: \((result as! NSError).localizedDescription)")
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.updateProgress()
                        })
                        
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
        
            let steps = NSNumber(integer: self.currentUser.currentSteps)
            let distance = self.currentUser.currentDistance
            let goal = NSNumber(integer: self.currentUser.currentGoal)
            let calories = self.currentUser.currentCalories
        
            self.stepCountLabel.text = "\(steps.commaDelimitedString()) / \(goal.commaDelimitedString())"
   
            let miles = distance * 0.00062137
            let mileString = NSString(format: "%0.1f", miles)
            self.distanceLabel.text = "\(mileString)"

            let calorieString = NSString(format: "%1.0f", (calories / 1000))
            self.calorieLabel.text = "\(calorieString) cal"
            self.calorieLabel.hidden = (calories == 0.0)
    }
    
    
}
