//
//  SettingsViewController.swift
//  EveryStep
//
//  Created by Stuart Buchbinder on 8/27/15.
//  Copyright © 2015 nakkotech. All rights reserved.
//

import UIKit
import CoreActionSheetPicker

class SettingsViewController: UITableViewController {
    
    let currentUser = ESUserController.defaultController.currentUser()
    
    enum Section : Int{
        case StepGoal = 0
        case IdleTimer = 1
        case Max = 2
    }


    @IBAction func pressedDoneButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Instance Methods

    private func displayStepGoalAlert() {
        let title = "New Goal"
        let message =  "Set a new daily step goal"
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert )
        
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action) -> Void in
          
            let textField = alertController.textFields![0]
            if textField.text!.isEmpty { return }
            self.currentUser.currentGoal = (textField.text! as NSString).integerValue

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadSections(NSIndexSet(index: Section.StepGoal.rawValue), withRowAnimation: UITableViewRowAnimation.None)
            })
        }
        
        alertController.addAction(saveAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        alertController.addAction(cancelAction)
        

        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.keyboardType = .NumberPad
        }
      
        
        
        presentViewController(alertController, animated: true, completion: nil)

    }
    
    private func displayIdleTimerAlert() {

        let picker = ActionSheetDatePicker(title: "Idle Time", datePickerMode: .CountDownTimer, selectedDate: NSDate(), doneBlock: { picker, value, index in
            
            let idleTime = value as! Int
            self.currentUser.idleTime = idleTime
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadSections(NSIndexSet(index: Section.IdleTimer.rawValue), withRowAnimation: .None)
            })
            
            
            }, cancelBlock: nil, origin: self.view)
        
        picker.countDownDuration = NSNumber(integer: currentUser.idleTime).doubleValue
     
        picker.showActionSheetPicker()
    }

    
    // MARK: - Cell Accessors
    
    private func textFieldCell(indexPath : NSIndexPath)->TextFieldCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("TextFieldCell", forIndexPath: indexPath) as! TextFieldCell
        
        if indexPath.section == Section.StepGoal.rawValue {
            let goal = NSNumber(integer: currentUser.currentGoal)
            cell.textField.text = goal.commaDelimitedString()
            
        } else if indexPath.section == Section.IdleTimer.rawValue {
            let idleTime = NSNumber(int: Int32(currentUser.idleTime))
            
            let hours = idleTime.timeFormattedStringWithTimeFormat(format: .Hours)
            let minutes = idleTime.timeFormattedStringWithTimeFormat(format: .Minutes)
            
            cell.textField.text = "\(hours) h \(minutes) min"

        }
        
        return cell
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Section.Max.rawValue
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

   
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return textFieldCell(indexPath)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == Section.StepGoal.rawValue {
            return "Daily Step Goal"
        } else if section == Section.IdleTimer.rawValue {
            return "Idle Timer"
        }
        return ""
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == Section.StepGoal.rawValue {
            displayStepGoalAlert()
        } else if indexPath.section == Section.IdleTimer.rawValue {
            displayIdleTimerAlert()
        }
    }


}

extension SettingsViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            // Hours
            return 25
        } else {
            // Minutes
            return 60
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("selected row : \(row) in component \(component)")
    }
    
  
}
