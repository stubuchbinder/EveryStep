//
//  ProgressView.swift
//  EveryStep
//
//  Created by Stuart Buchbinder on 8/27/15.
//  Copyright © 2015 nakkotech. All rights reserved.
//

import UIKit

@IBDesignable
class ProgressView: UIView {

    @IBInspectable var gutterColor : UIColor = UIColor.darkGrayColor() {
        didSet {
            configure()
        }
    }
    
    @IBInspectable var fillColor : UIColor = UIColor.everyStepBlueColor() {
        didSet {
            configure()
        }
    }
    
    @IBInspectable var lineWidth : Float = 10.0 {
        didSet {
            configure()
        }
    }
    
    @IBInspectable var progress : Float = 0.0 {
        didSet {
            configure()
        }
    }
    
    
    let backgroundLayer = CAShapeLayer()
    let foregroundLayer = CAShapeLayer()
    

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        configure()
    }
    
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupShapeLayer(backgroundLayer)
        setupShapeLayer(foregroundLayer)
    }
    
    
   
    private func setup() {
        backgroundLayer.fillColor = UIColor.clearColor().CGColor
        backgroundLayer.strokeEnd = 1
        backgroundLayer.strokeColor = gutterColor.CGColor
        self.layer.addSublayer(backgroundLayer)
        
        foregroundLayer.fillColor = UIColor.clearColor().CGColor
        foregroundLayer.strokeEnd = 0
        foregroundLayer.strokeColor = fillColor.CGColor
        self.layer.addSublayer(foregroundLayer)
    }
    
    private func configure() {
        backgroundLayer.strokeColor = gutterColor.CGColor
        foregroundLayer.strokeColor = fillColor.CGColor
        
        backgroundLayer.lineWidth = CGFloat(lineWidth)
        foregroundLayer.lineWidth = CGFloat(lineWidth)
        
        foregroundLayer.strokeEnd = CGFloat(progress)
    }
    
    private func setupShapeLayer(layer : CAShapeLayer) {
        let frame = self.bounds
        let center = CGPoint(x: frame.width * 0.5, y: frame.height * 0.5)
        let radius = CGFloat(CGRectGetWidth(frame) * 0.35)
        let startAngle = DegreesToRadians(135.0)
        let endAngle = DegreesToRadians(45.0)
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        layer.path = path.CGPath
    }
    
    func DegreesToRadians (value:CGFloat) -> CGFloat {
        return value * CGFloat(M_PI) / 180.0
    }
}
