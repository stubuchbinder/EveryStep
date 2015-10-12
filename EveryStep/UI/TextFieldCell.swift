//
//  TextFieldCell.swift
//  EveryStep
//
//  Created by Stuart Buchbinder on 10/9/15.
//  Copyright © 2015 nakkotech. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.font = UIFont(name: "Avenir", size: 14)
            textField.textColor = UIColor.darkGrayColor()
            textField.userInteractionEnabled = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
