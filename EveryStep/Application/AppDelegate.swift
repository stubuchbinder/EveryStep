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
        
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        let alertController = UIAlertController(title: nil, message: notification.alertBody, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil);
        
        alertController.addAction(alertAction)
        
        self.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    }

    
    func sheduleIdleTimerNotification() {
        
        // Cancel all pending local notifications
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        let notification = UILocalNotification()
        notification.alertBody = "You've been idle too long. Get up and walk around!"
 
        let deliveryDate = NSDate().dateByAddingTimeInterval(Double(ESUserController.defaultController.currentUser().idleTime))
        notification.fireDate = deliveryDate
      
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }


}

