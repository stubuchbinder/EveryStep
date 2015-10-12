//
//  SettingsViewController.swift
//  EveryStep
//
//  Created by Stuart Buchbinder on 8/27/15.
//  Copyright © 2015 nakkotech. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    let currentUser = ESUserController.defaultController.currentUser()
    
    enum Section : Int{
        case StepGoal = 0
        case IdleTimer = 1
        case Max = 2
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let title = "Idle Time"
        let message = "Remind me to get up in:"
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
        
        let picker = UIPickerView(frame: alertController.view.bounds)
        picker.center.x = alertController.view.center.x
        picker.center.y = alertController.view.center.y
        picker.dataSource = self
        picker.delegate = self
        
        alertController.view.addSubview(picker)
        
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action) -> Void in
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }

    
    // MARK: - Cell Accessors
    
    private func textFieldCell(indexPath : NSIndexPath)->TextFieldCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("TextFieldCell", forIndexPath: indexPath) as! TextFieldCell
        
        if indexPath.section == Section.StepGoal.rawValue {
            let goal = NSNumber(integer: currentUser.currentGoal)
            cell.textField.text = goal.commaDelimitedString()
            
        } else if indexPath.section == Section.IdleTimer.rawValue {
            let idleTime = NSNumber(int: currentUser.idleTime)
            
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
