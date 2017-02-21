//
//  RectCornerView.swift
//  VGClient
//
//  Created by jie on 2017/2/13.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

@IBDesignable
class RectCornerView: UIView {
    
    struct Shadow {
        let color: UIColor
        let radius: CGFloat
        let opacity: Float
        let offset: CGSize
    }
    
    /// Background
    @IBInspectable var fillColor: UIColor = .white

    /// Corner
    @IBInspectable var cornerRadiusX: CGFloat = 20.0
    @IBInspectable var cornerRadiusY: CGFloat = 20.0
    @IBInspectable var isTopLeftCorner: Bool = true
    @IBInspectable var isTopRightCorner: Bool = true
    @IBInspectable var isBottomLeftCorner: Bool = false
    @IBInspectable var isBottomRightCorner: Bool = false
    
    /// Shadow
    @IBInspectable var isShadowEnabled: Bool = true
    @IBInspectable var shadowColor: UIColor = .darkGray
    @IBInspectable var shadowRadius: CGFloat = 15.0
    @IBInspectable var shadowOpacity: Float = 0.4
    @IBInspectable var shadowOffsetX: CGFloat = 0
    @IBInspectable var shadowOffsetY: CGFloat = -2
    
    private var rectCorner: UIRectCorner {
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
    
    
    /// Life cycle
    
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
        
        if isShadowEnabled {
            addShadow()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: rectCorner,
                                cornerRadii: CGSize(width: cornerRadiusX, height: cornerRadiusY))
        ctx.beginPath()
        ctx.addPath(path.cgPath)
        ctx.setFillColor(fillColor.cgColor)
        ctx.fillPath()
    }
    
    
    /// Background
    
    func setFillColor(color: UIColor) {
        
        fillColor = color
        
        setNeedsDisplay()
    }
    
    /// Corner
    
    func setCornerRadiusX(radius: CGFloat) {
        
        cornerRadiusX = radius
        
        setNeedsDisplay()
    }
    
    func setCornerRadius(x: CGFloat, y: CGFloat) {
        cornerRadiusX = x
        cornerRadiusY = y
        
        setNeedsDisplay()
    }
    
    func setCornerRadiusY(radius: CGFloat) {
        
        cornerRadiusY = radius
        
        setNeedsDisplay()
    }
    
    /// Shadow
    func addShadow() {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetX, height: shadowOffsetY)
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
    }
    
    func setShadow(shadow: Shadow) {
        shadowColor = shadow.color
        shadowRadius = shadow.radius
        shadowOpacity = shadow.opacity
        shadowOffsetX = shadow.offset.width
        shadowOffsetY = shadow.offset.height
        
        addShadow()
    }
    
    func removeShadow() {
        layer.shadowColor = nil
        layer.shadowOpacity = 0.0
    }
}
