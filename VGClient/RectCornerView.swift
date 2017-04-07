//
//  RectCornerView.swift
//  VGClient
//
//  Created by jie on 2017/2/13.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

@IBDesignable
open class RectCornerView: UIView {
    
    public struct Shadow {
        let color: UIColor
        let radius: CGFloat
        let opacity: Float
        let offset: CGSize
    }
    
    /// Background
    @IBInspectable public var fillColor: UIColor = .white {
        didSet {
            setNeedsDisplay()
        }
    }

    /// Corner
    @IBInspectable public var cornerRadiusX: CGFloat = 20.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var cornerRadiusY: CGFloat = 20.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var isTopLeftCorner: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var isTopRightCorner: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var isBottomLeftCorner: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var isBottomRightCorner: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Shadow
    @IBInspectable public var isShadowEnabled: Bool = true {
        didSet {
            if isShadowEnabled {
                addShadow()
            } else {
                removeShadow()
            }
        }
    }
    
    @IBInspectable public var shadowColor: UIColor = .darkGray {
        didSet {
            addShadow()
        }
    }
    
    @IBInspectable public var shadowRadius: CGFloat = 15.0 {
        didSet {
            addShadow()
        }
    }
    
    @IBInspectable public var shadowOpacity: Float = 0.4 {
        didSet {
            addShadow()
        }
    }
    
    @IBInspectable public var shadowOffsetX: CGFloat = 0 {
        didSet {
            addShadow()
        }
    }
    
    @IBInspectable public var shadowOffsetY: CGFloat = -2 {
        didSet {
            addShadow()
        }
    }
    
    /// make rect corner
    private var rectCorner: UIRectCorner {
        
        var corner = UIRectCorner()
        
        if isTopLeftCorner {
            corner.insert(.topLeft)
        }
        if isTopRightCorner {
            corner.insert(.topRight)
        }
        if isBottomLeftCorner {
            corner.insert(.bottomLeft)
        }
        if isBottomRightCorner {
            corner.insert(.bottomRight)
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
    
    fileprivate func initialization() {
        backgroundColor = UIColor.clear
        
        if isShadowEnabled {
            addShadow()
        }
    }
    
    open override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: rectCorner,
                                cornerRadii: CGSize(width: cornerRadiusX,
                                                    height: cornerRadiusY))
        ctx.beginPath()
        ctx.addPath(path.cgPath)
        ctx.setFillColor(fillColor.cgColor)
        ctx.fillPath()
    }
    
    // MARK: -  Shadow
    
    public func addShadow() {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetX, height: shadowOffsetY)
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
    }
    
    public func removeShadow() {
        layer.shadowColor = nil
        layer.shadowOpacity = 0.0
    }
}
