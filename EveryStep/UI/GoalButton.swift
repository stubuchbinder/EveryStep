//
//  GoalButton.swift
//  EveryStep
//
//  Created by Stuart Buchbinder on 9/23/15.
//  Copyright © 2015 nakkotech. All rights reserved.
//

import UIKit

@IBDesignable
class GoalButton: UIButton {

    @IBInspectable var cornerRadius : CGFloat = 10.0 {
        didSet {
            config()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        config()
    }
    
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        config()
    }
    
    private func config() {
        layer.cornerRadius = cornerRadius
    }

}
