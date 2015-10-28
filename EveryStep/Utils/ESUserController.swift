//
//  ESUserController.swift
//  EveryStep
//
//  Created by Stuart Buchbinder on 9/23/15.
//  Copyright © 2015 nakkotech. All rights reserved.
//

import Foundation


// MARK: - ESUserController
class ESUserController {
    
    let URL_PATH = "EVERYSTEP_USER"
    private var user : ESUser?
    
    
    /**
        Singleton accessor
    */
    class var defaultController : ESUserController {
        struct Singleton {
            static let instance = ESUserController()
        }
        return Singleton.instance
    }
    
    
    /**
        Save the user to disk with closure
    */
    func saveUser(completion completion:((success : Bool) -> Void)?) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let docsDir = dirPaths[0]
            let filePath = NSURL(string: docsDir)!.URLByAppendingPathComponent(self.URL_PATH)
            
            var success = false
            if let userToSave = self.user {
                success = NSKeyedArchiver.archiveRootObject(userToSave, toFile: filePath.description)
            }
            
            if completion != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion!(success: success)
                })
            }
            
        }
    }
    
    /**
        Retrieve the current user from the disk if it esists. If the user does not exist, create one and return it
    */
    func currentUser() -> ESUser {
        if user == nil {
            let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let docsDir = dirPaths[0] as String
            let filePath = (NSURL(string: docsDir))!.URLByAppendingPathComponent(self.URL_PATH)
            
            /// Return the NewsyUser if exits, otherwise send a new NewsyUser with standard defaults
            if (NSFileManager.defaultManager().fileExistsAtPath(filePath.description)) {
                self.user = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath.description) as? ESUser
            }
            else {
                self.user = ESUser()
            }
        }
        return user!
    }
}


// MARK: - ESUser
class ESUser : NSObject, NSCoding {
    
    // Daily step goal
    var currentGoal : Int = 10000 {
        didSet {
            ESUserController.defaultController.saveUser(completion: nil)
        }
    }
    
    // Total number of steps the user has taken today
    var currentSteps : Int = 0 {
        didSet {
            ESUserController.defaultController.saveUser(completion: nil)
        }
    }
    
    // Distance the user has walked today
    var currentDistance : Double = 0.0 {
        didSet {
            ESUserController.defaultController.saveUser(completion: nil)
        }
    }
    
    // Daily active calorie burn
    var currentCalories : Double = 0.0 {
        didSet {
            ESUserController.defaultController.saveUser(completion: nil)
        }
    }
    
    // Local notification is sent when the user has been sitting idle for an hour
    var idleTime : Int = (60 * 60) {
        didSet {
            ESUserController.defaultController.saveUser(completion: nil)
        }
    }
    
    // The date of the last synchronization between the apple watch and the app (currently not used)
    var lastUpdate : NSDate = NSDate() {
        didSet {
            ESUserController.defaultController.saveUser(completion: nil)
        }
    }
    
    
    override init() {
        super.init()
    }


    /**
     Initialize user variables from the NSCoder
    */
    required init(coder aDecoder: NSCoder) {
        
        let steps = aDecoder.decodeIntForKey("steps")
        let goal = aDecoder.decodeIntForKey("goal")
        let distance = aDecoder.decodeDoubleForKey("distance")
        let calories = aDecoder.decodeDoubleForKey("calories")
        let idleTime = aDecoder.decodeIntForKey("idleTime")
        let lastUpdate = aDecoder.decodeObjectForKey("lastUpdate") as! NSDate
        
        self.currentSteps = Int(steps)
        self.currentGoal = Int(goal)
        self.currentDistance = distance
        self.currentCalories = calories
        self.idleTime = Int(idleTime)
        self.lastUpdate = lastUpdate
        
        
    }
    
    /**
     Save user values to NSCoder
    */
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(self.currentSteps, forKey: "steps")
        aCoder.encodeInteger(self.currentGoal, forKey: "goal")
        aCoder.encodeDouble(self.currentDistance, forKey: "distance")
        aCoder.encodeDouble(self.currentCalories, forKey: "calories")
        aCoder.encodeInteger(self.idleTime, forKey: "idleTime")
        aCoder.encodeObject(self.lastUpdate, forKey: "lastUpdate")
    }
    

    

}
