//
//  RectCornerView.swift
//  VGClient
//
//  Created by jie on 2017/2/13.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

@IBDesignable
public class RectCornerView: UIView {
    
    public struct Shadow {
        let color: UIColor
        let radius: CGFloat
        let opacity: Float
        let offset: CGSize
    }
    
    /// Background
    @IBInspectable public var fillColor: UIColor = .white

    /// Corner
    @IBInspectable public var cornerRadiusX: CGFloat = 20.0
    @IBInspectable public var cornerRadiusY: CGFloat = 20.0
    @IBInspectable public var isTopLeftCorner: Bool = true
    @IBInspectable public var isTopRightCorner: Bool = true
    @IBInspectable public var isBottomLeftCorner: Bool = false
    @IBInspectable public var isBottomRightCorner: Bool = false
    
    /// Shadow
    @IBInspectable public var isShadowEnabled: Bool = true
    @IBInspectable public var shadowColor: UIColor = .darkGray
    @IBInspectable public var shadowRadius: CGFloat = 15.0
    @IBInspectable public var shadowOpacity: Float = 0.4
    @IBInspectable public var shadowOffsetX: CGFloat = 0
    @IBInspectable public var shadowOffsetY: CGFloat = -2
    
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
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialization()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialization()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        initialization()
    }
    
    fileprivate func initialization() {
        backgroundColor = UIColor.clear
        
        if isShadowEnabled {
            addShadow()
        }
    }
    
    public override func draw(_ rect: CGRect) {
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
    
    public func setFillColor(color: UIColor) {
        
        fillColor = color
        
        setNeedsDisplay()
    }
    
    /// Corner
    
    public func setCornerRadiusX(radius: CGFloat) {
        
        cornerRadiusX = radius
        
        setNeedsDisplay()
    }
    
    public func setCornerRadius(x: CGFloat, y: CGFloat) {
        cornerRadiusX = x
        cornerRadiusY = y
        
        setNeedsDisplay()
    }
    
    public func setCornerRadiusY(radius: CGFloat) {
        
        cornerRadiusY = radius
        
        setNeedsDisplay()
    }
    
    /// Shadow
    public func addShadow() {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetX, height: shadowOffsetY)
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
    }
    
    public func setShadow(shadow: Shadow) {
        shadowColor = shadow.color
        shadowRadius = shadow.radius
        shadowOpacity = shadow.opacity
        shadowOffsetX = shadow.offset.width
        shadowOffsetY = shadow.offset.height
        
        addShadow()
    }
    
    public func removeShadow() {
        layer.shadowColor = nil
        layer.shadowOpacity = 0.0
    }
}
