//
//  AppDelegate.swift
//  EveryStep
//
//  Created by Stuart Buchbinder on 8/27/15.
//  Copyright © 2015 nakkotech. All rights reserved.
//

import UIKit
import MessageUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Register for notifications so we can add an 'Idle' alert to tell the user to get up and move around
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        return true
    }


    func applicationDidBecomeActive(application: UIApplication) {
        ESUserDefaults.standardUserDefaults.incrementLaunchCount()
        
        if ESUserDefaults.standardUserDefaults.shouldDisplayRating() {
            let controller = RatingViewController()
            controller.delegate = self
            self.window?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
        }
    }
    /**
        Received a local ('Idle') notification. Display an alert to the user if the app is active
    **/
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        let alertController = UIAlertController(title: nil, message: notification.alertBody, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil);
        
        alertController.addAction(alertAction)
        
        self.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    }

    /**
        Schedules an 'idle' notification to let the user that they've been sitting for too long and need to get up and move around
    **/
    func sheduleIdleTimerNotification() {
        
        // Cancel all pending local notifications
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        // Create the notification
        let notification = UILocalNotification()
        notification.alertBody = "You've been idle too long. Get up and walk around!"
 
        // Fire date is based on the user's settings
        let deliveryDate = NSDate().dateByAddingTimeInterval(Double(ESUserController.defaultController.currentUser().idleTime))
        notification.fireDate = deliveryDate
        
        // Schedule the notification
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }


}

extension AppDelegate : RatingViewControllerDelegate {
    func ratingViewControllerDidCancel() {
        ESUserDefaults.standardUserDefaults.resetLaunchCount()
    }
    
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
            
            self.window?.rootViewController?.presentViewController(mailComposeController, animated: true, completion: { () -> Void in
                UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
            })
            
        } else {
//            UIAlertView(title: "Cannot Send Mail", message: "A valid email account must be added in order to use this feature", delegate: nil, cancelButtonTitle: "OK").show()
        }

    }
    
    func ratingViewControllerDidPressRateButton(rating: Int) {
        let appUrlString = "https://itunes.apple.com/us/app/every-step/id942810364"
        UIApplication.sharedApplication().openURL(NSURL(string: appUrlString)!)
    }
}

extension AppDelegate: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        self.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

}

