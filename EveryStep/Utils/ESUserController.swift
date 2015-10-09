//
//  ESUserController.swift
//  EveryStep
//
//  Created by Stuart Buchbinder on 9/23/15.
//  Copyright © 2015 nakkotech. All rights reserved.
//

import Foundation

class ESUserController {
    
    let URL_PATH = "EVERYSTEP_USER"
    
    private var user : ESUser?
    

    class var defaultController : ESUserController {
        struct Singleton {
            static let instance = ESUserController()
        }
        return Singleton.instance
    }
    
    
    /**
        Save the user to disk with closure
    **/
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
        Retrieve the current user from the disk if it esists. 
    
        If the user does not exist, create one and return it
    **/
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


class ESUser : NSObject {
    
    var currentGoal : Int!{
        didSet {
            ESUserController.defaultController.saveUser(completion: nil)
        }
    }
    
    var currentSteps : Int! {
        didSet {
            ESUserController.defaultController.saveUser(completion: nil)
        }
    }
    
    var currentDistance : Double! {
        didSet {
            ESUserController.defaultController.saveUser(completion: nil)
        }
    }
    
    var currentCalories : Double! {
        didSet {
            ESUserController.defaultController.saveUser(completion: nil)
        }
    }
    
    var idleTime : Int32 = 60 * 60 {
        didSet {
            ESUserController.defaultController.saveUser(completion: nil)
        }
    }
    
    var lastUpdate : NSDate? {
        didSet {
            ESUserController.defaultController.saveUser(completion: nil)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        self.currentGoal = aDecoder.decodeObjectForKey("currentGoal") as! Int
        self.currentSteps = aDecoder.decodeObjectForKey("currentSteps") as! Int
        self.lastUpdate = aDecoder.decodeObjectForKey("lastUpdate") as? NSDate
        self.currentDistance = aDecoder.decodeDoubleForKey("currentDistance")
        self.currentCalories = aDecoder.decodeDoubleForKey("currentCalories")
        self.idleTime = aDecoder.decodeIntForKey("idleTime")
    
    }
    
    override init() {
        
        self.currentGoal = 10000
        self.currentDistance = 0.0
        self.currentSteps = 0
        self.currentCalories = 0.0
        self.idleTime = 60 * 60
        self.lastUpdate = NSDate()
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(currentGoal, forKey: "currentGoal")
        aCoder.encodeInteger(currentSteps, forKey: "currentSteps")
        aCoder.encodeObject(currentDistance, forKey: "currentDistance")
        aCoder.encodeDouble(currentCalories, forKey: "currentCalories")
        aCoder.encodeInt(idleTime, forKey: "idleTime")
        aCoder.encodeObject(lastUpdate, forKey: "lastUpdate")
    }
}
