//
//  ActivityInterfaceController.swift
//  EveryStep
//
//  Created by Stuart Buchbinder on 10/28/15.
//  Copyright © 2015 nakkotech. All rights reserved.
//

import WatchKit
import Foundation


class ActivityInterfaceController: WKInterfaceController {

    @IBOutlet var stepCountLabel: WKInterfaceLabel?
    @IBOutlet var distanceLabel: WKInterfaceLabel?
    @IBOutlet var calorieLabel: WKInterfaceLabel?

    let currentUser = ESUserController.defaultController.currentUser()
    
    
    // MARK: Lifecycle
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "activityNotification:", name: Notification.Activity.rawValue, object: nil)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        update()
        
        if let extDelegate = WKExtension.sharedExtension().delegate as? ExtensionDelegate {
            extDelegate.loadData()
        }
    }

    
    // MARK: -
    
    func activityNotification(notification : NSNotification) {
        update()
    }
    
    private func update() {
        if let _ = stepCountLabel {
            stepCountLabel!.setText(NSNumber(integer: currentUser.currentSteps).commaDelimitedString())
        }
        
        if let _ = distanceLabel {
            let distance = NSString(format: "%0.1f", self.currentUser.currentDistance).floatValue
            let miles : CGFloat = CGFloat(distance) * CGFloat(0.00062137)
            let milesString = NSString(format: "%0.1f", miles)
            distanceLabel!.setText(milesString as String)
        }
        
        if let _ = calorieLabel {
            let totalCalories = NSString(format: "%0.1f", self.currentUser.currentCalories / 1000)
            calorieLabel?.setText(totalCalories as String)
        }
    }

}
