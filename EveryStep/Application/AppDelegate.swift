//
//  AppDelegate.swift
//  EveryStep
//
//  Created by Stuart Buchbinder on 8/27/15.
//  Copyright © 2015 nakkotech. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Register for notifications so we can add an 'Idle' alert to tell the user to get up and move around
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        return true
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

