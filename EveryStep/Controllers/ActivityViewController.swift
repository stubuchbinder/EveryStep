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
import MessageUI

class ActivityViewController: UIViewController {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var stepCountLabel: UILabel!
    @IBOutlet weak var goalButton: GoalButton!
    @IBOutlet weak var progressView: ProgressView!
    
    let currentUser = ESUserController.defaultController.currentUser()
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
            self.calorieLabel.hidden = (calories == 0.0)
        }
    }
    
    var lastUpdate : NSDate = NSDate() {
        didSet {
            currentUser.lastUpdate = lastUpdate
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        calorieLabel.hidden = true
        
        startSession()
        
        // reload any data when the app returns from the background
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (note : NSNotification) -> Void in
            self.loadData()
        }
        
        loadData()
    }
    
    
    /**
     Refresh UI for any changes that may have happened on the settings screen
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateProgress()
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
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
        //        if let session = session where session.reachable {
        //            session.sendMessage(["steps": steps, "calories": calories, "distance": distance, "lastUpdate" : NSDate()], replyHandler: nil, errorHandler: { (error) -> Void in
        //                print(error)
        //            })
        //        }
        
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
        
        let healthKitManager = HKManager.defaultManager
        let pedometerManager = CMPedometerManager.defaultManager
        
        if healthKitManager.isAuthorized {
            
            
            pedometerManager.currentPedometerData({ (success, result) -> Void in
                if success == false {
                    print("Error getting step count: \(result as! NSError)")
                } else {
                    if let data = result as? CMPedometerData {
                        
                        self.steps = data.numberOfSteps.integerValue
                        self.distance = (data.distance?.doubleValue)!
                        self.lastUpdate = data.endDate
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.updateProgress()
                            self.broadcast()
                        })
                    }
                }
            })
            
            healthKitManager.activeEnergyBurned({ (success, result) -> Void in
                if success == true {
                    self.calories = result as! Double
                } else {
                    self.calories = 0.0
                    print("Error getting distance: \((result as! NSError).localizedDescription)")
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.updateProgress()
                    self.broadcast()
                    
                })
                
            })
            
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
    
    
    
    
    /**
     Refreshes the UI based on the data in 'currentUser'
     */
    func updateProgress() {
        
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
        
        // Convert distance (meters) to miles
        let miles = distance * 0.00062137
        let mileString = NSString(format: "%0.1f", miles)
        self.distanceLabel.text = "\(mileString) miles"
        
        // Calories
        
        let calorieString = NSString(format: "%1.0f", (calories / 1000))
        self.calorieLabel.text = "\(calorieString) cals"
        
        // reset idle timer and start it again
        (UIApplication.sharedApplication().delegate as! AppDelegate).sheduleIdleTimerNotification()
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
    
    func displayRatingAlert() {
        let vc = RatingViewController()
        vc.delegate = self
        self.presentViewController(vc, animated: true, completion: nil)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: "rateThisApp")
        defaults.synchronize()
    }
    
}

extension ActivityViewController: RatingViewControllerDelegate {
    func ratingViewControllerDidPressFeedbackButton() {
        
        if MFMailComposeViewController.canSendMail() {
            
            let mailComposeController = MFMailComposeViewController()
            mailComposeController.mailComposeDelegate = self
            mailComposeController.setSubject("iOS App Feedback")
            mailComposeController.setToRecipients(["stu@stubuchbinder.com"])
            
            let infoDictionary : NSDictionary = NSDictionary(dictionary: NSBundle.mainBundle().infoDictionary!)
            
            let appVersion = infoDictionary["CFBundleShortVersionString"] as! String
            let model = "device model"
            let systemVersion = UIDevice.currentDevice().systemVersion
            let deviceInfoString = "Device Info: <font size=\"1\"><br>version: \(appVersion)<br>\(model), \(systemVersion)</font>"
            
            mailComposeController.setMessageBody(deviceInfoString, isHTML: true)
            
            self.presentViewController(mailComposeController, animated: true, completion: { () -> Void in
                UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
            })
            
        } else {
            let alertController = UIAlertController(title: "Cannot Send Mail", message: "A valid email account must be added in order to use this feature", preferredStyle: .Alert)
            
            alertController.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (action: UIAlertAction) -> Void in
                
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        
        }
        

    }
    
    func ratingViewControllerDidPressRateButton(rating: Int) {
        let appId = "942810364"
        let appURL = NSURL(string: "http://itunes.apple.com/app/id\(appId)")!
        UIApplication.sharedApplication().openURL(appURL)

    }
    
    func ratingViewControllerDidCancel() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(false, forKey: "rateThisApp")
        defaults.synchronize()
    }
}

extension ActivityViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
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
                
                self.updateProgress()
                
            })
        }
        
    }
    
    
}
