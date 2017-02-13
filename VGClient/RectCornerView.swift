//
//  RectCornerView.swift
//  VGClient
//
//  Created by jie on 2017/2/13.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

class RectCornerView: UIView {
    
    @IBInspectable var isShadowing: Bool = true
    @IBInspectable var isTopLeftCorner: Bool = true
    @IBInspectable var isTopRightCorner: Bool = true
    @IBInspectable var isBottomLeftCorner: Bool = false
    @IBInspectable var isBottomRightCorner: Bool = false
    @IBInspectable var cornerRadius: CGFloat = 15.0
    @IBInspectable var fillColor: UIColor = .white
    
    var rectCorner: UIRectCorner {
        var corner = UIRectCorner.allCorners
        if !isTopLeftCorner {
            corner.remove(UIRectCorner.topLeft)
        }
        if !isTopRightCorner {
            corner.remove(UIRectCorner.topRight)
        }
        if !isBottomLeftCorner {
            corner.remove(UIRectCorner.bottomLeft)
        }
        if !isBottomRightCorner {
            corner.remove(UIRectCorner.bottomRight)
        }
        return corner
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialization()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialization()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialization()
    }
    
    func initialization() {
        backgroundColor = UIColor.clear
        
        if isShadowing {
            addShadow()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: rectCorner,
                                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        ctx.beginPath()
        ctx.addPath(path.cgPath)
        ctx.setFillColor(fillColor.cgColor)
        ctx.fillPath()
    }
    
    func setCornerRadius(radius: CGFloat) {
        
        cornerRadius = radius
        
        setNeedsDisplay()
    }
    
    func setFillColor(color: UIColor) {
        
        fillColor = color
        
        setNeedsDisplay()
    }
    
    func addShadow() {
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowRadius = 15
        layer.shadowOpacity = 0.4
    }
    
}
