//
//  RatingViewController.swift
//  Newsy
//
//  Created by Stuart Buchbinder on 11/11/15.
//  Copyright © 2015 Stuart Buchbinder. All rights reserved.
//

import UIKit

protocol RatingViewControllerDelegate {
    func ratingViewControllerDidPressRateButton(rating : Int)
    func ratingViewControllerDidPressFeedbackButton()
    func ratingViewControllerDidCancel()
}

class RatingViewController: UIViewController {
    
    enum State {
        case Rate, Feedback
        
        func title()->String {
            switch(self) {
            case .Rate:
                return "Love Every Step?"
            case .Feedback:
                return "We are sorry that the app is not working well for you."
                
            }
        }
        
        func message()->String {
            switch(self) {
            case .Rate:
                return "Please let us know what you think of this version of the Every Step app."
                
            case .Feedback:
                return "Please let us know how we can improve the experience."
            }
        }
        
        func rateButton()->String {
            switch (self) {
            case .Rate:
                return "Rate"
                
            case .Feedback:
                return "Ok"
            }
        }
    }
    
    var transitioner : RatingAlertTransitioner
    var currentState : State = .Rate {
        didSet {
            animateState()
        }
    }
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var StarContentView: UIView!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!
    
    var currentRating = 5
    var delegate : RatingViewControllerDelegate?
    
    
    let maxRating = 5
    
    
    // MARK: - Lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.transitioner = RatingAlertTransitioner()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .Custom
        self.transitioningDelegate = self.transitioner
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    convenience init() {
        self.init(nibName: "RatingViewController", bundle: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateStarDisplay()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        NewsyTracker.sharedTracker.trackScreen(screen: "Rating Screen")
    }
    
    
    
    // MARK: - IBActions
    @IBAction func pressedCancelButton(sender : AnyObject?) {
        
        if let _ = delegate {
            delegate!.ratingViewControllerDidCancel()
        }
        
        self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func pressedRateButton(sender : AnyObject?) {
        
        if currentState == .Rate {
            if currentRating < 4 {
                currentState = .Feedback
                return
            }
            
            if let _ = delegate {
                delegate!.ratingViewControllerDidPressRateButton(currentRating)
            }
        } else {
            if let _ = delegate {
                delegate!.ratingViewControllerDidPressFeedbackButton()
            }
        }
        
        self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func pressedStarButton(sender : AnyObject?) {
        
        if let btn = sender as? UIButton {
            currentRating = btn.tag
            updateStarDisplay()
        }

    }
    
    // MARK: - 
    
    private func updateStarDisplay() {
        
        let emptyStar = UIImage(named: "StarEmpty")
        let fullStar = UIImage(named: "StarFull")
   
        switch (currentRating) {
        case 1:
            star1.setImage(fullStar, forState: .Normal)
            star2.setImage(emptyStar, forState: .Normal)
            star3.setImage(emptyStar, forState: .Normal)
            star4.setImage(emptyStar, forState: .Normal)
            star5.setImage(emptyStar, forState: .Normal)
            
            
        case 2:
            star1.setImage(fullStar, forState: .Normal)
            star2.setImage(fullStar, forState: .Normal)
            star3.setImage(emptyStar, forState: .Normal)
            star4.setImage(emptyStar, forState: .Normal)
            star5.setImage(emptyStar, forState: .Normal)
         
            
        case 3:
            star1.setImage(fullStar, forState: .Normal)
            star2.setImage(fullStar, forState: .Normal)
            star3.setImage(fullStar, forState: .Normal)
            star4.setImage(emptyStar, forState: .Normal)
            star5.setImage(emptyStar, forState: .Normal)
    
            
        case 4:
            star1.setImage(fullStar, forState: .Normal)
            star2.setImage(fullStar, forState: .Normal)
            star3.setImage(fullStar, forState: .Normal)
            star4.setImage(fullStar, forState: .Normal)
            star5.setImage(emptyStar, forState: .Normal)
        
        case 5:
            star1.setImage(fullStar, forState: .Normal)
            star2.setImage(fullStar, forState: .Normal)
            star3.setImage(fullStar, forState: .Normal)
            star4.setImage(fullStar, forState: .Normal)
            star5.setImage(fullStar, forState: .Normal)
            
        default:
            break
       
        }
        
    }
    
    
    private func animateState() {
        
       let duration = 0.3
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.titleLabel.alpha = 0
            self.messageLabel.alpha = 0
            self.StarContentView.alpha = (self.currentState == .Rate) ? 1.0 : 0.0
            
            
            }) { _ in
                
                self.titleLabel.text = self.currentState.title()
                self.messageLabel.text = self.currentState.message()
                self.rateButton.setTitle(self.currentState.rateButton(), forState: .Normal)
                UIView.animateWithDuration(duration, animations: { () -> Void in
                    self.titleLabel.alpha = 1
                    self.messageLabel.alpha = 1
                })
                
        }
        
    }
    
    
 
}




