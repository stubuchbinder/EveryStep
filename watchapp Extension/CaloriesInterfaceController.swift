//
//  CaloriesInterfaceController.swift
//  EveryStep
//
//  Created by Stuart Buchbinder on 10/7/15.
//  Copyright © 2015 nakkotech. All rights reserved.
//

import WatchKit
import Foundation


class CaloriesInterfaceController: WKInterfaceController {

    let healthKitManager = HKManager.defaultManager
    
    var caloriesBurned : Double = 0
    @IBOutlet var calorieLabel: WKInterfaceLabel!

    override func didAppear() {
        super.didAppear()
        loadData()
    }
    
    func loadData() {
        
        healthKitManager.activeEnergyBurned { (success, result) -> Void in
            if success == true {
                self.caloriesBurned = (result as? Double)!
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.updateProgress()
            })
        }
        
    }
    
    private func updateProgress() {
        let calorieString = NSString(format: "%1.0f", (caloriesBurned / 1000))
        calorieLabel.setText(calorieString as String)
    }
    
    

}
