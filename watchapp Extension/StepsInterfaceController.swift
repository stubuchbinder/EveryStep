//
//  StepsInterfaceController.swift
//  EveryStep
//
//  Created by Stuart Buchbinder on 10/7/15.
//  Copyright © 2015 nakkotech. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion


class StepsInterfaceController: WKInterfaceController {
    
    let pedometerManager = CMManager.defaultManager
    let currentUser = ESUserController.defaultController.currentUser()

    @IBOutlet var stepLabel: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        updateProgress()
    }
    
    override func willActivate() {
        super.willActivate()
        loadData()
    }

    
    private func loadData() {
        
        pedometerManager.dailyPedometerData { (success, result) -> Void in
            if success {
                if let data = result as? CMPedometerData {
                    self.currentUser.currentSteps = data.numberOfSteps
                    self.currentUser.currentDistance = data.distance
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.updateProgress()
                    })
                }
            }
        }
        
    }
    
    private func updateProgress() {
        let steps = currentUser.currentSteps
        stepLabel.setText(steps.commaDelimitedString())
    }

}
