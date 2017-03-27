//
//  BorderTextField.swift
//  VGClient
//
//  Created by viwii on 2017/3/25.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

/// Border Number
///
public struct BorderNumber: OptionSet {

    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static let top = BorderNumber(rawValue: 1<<0)
    
    public static let left = BorderNumber(rawValue: 1<<1)
    
    public static let bottom = BorderNumber(rawValue: 1<<2)
    
    public static let right = BorderNumber(rawValue: 1<<3)
}



/// CGRect的四个顶点。
///
public extension CGRect {
    
    public var topLeft: CGPoint {
        return CGPoint(x: 1, y: 1)
    }
    
    public var topRight: CGPoint {
        return CGPoint(x: width - 1, y: 1)
    }
    
    public var bottomLeft: CGPoint {
        return CGPoint(x: 1, y: height - 1)
    }
    
    public var bottomRight: CGPoint {
        return CGPoint(x: width - 1, y: height - 1)
    }
}




/// Best use in storyboard
///
@IBDesignable open class BorderTextField: UITextField {
    
    /// which border;
    /// `default` is bottom;
    @IBInspectable open var borderNumber: UInt = 1<<2
    
    /// background color
    
    @IBInspectable open var isFilled: Bool = false
    
    @IBInspectable open var fillColor: UIColor = .clear
    
    /// stoke
    @IBInspectable open var strokeColor: UIColor = .black
    
    /// line
    
    @IBInspectable open var isLineDash: Bool = false
    
    @IBInspectable open var lineWidth: CGFloat = 2.0
    
    @IBInspectable open var lineDash: CGFloat = 1.0
    
    
    open override func draw(_ rect: CGRect) {

        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        
        /// fill rect
        
        if isFilled {
            
            ctx.beginPath()
            
            ctx.setFillColor(fillColor.cgColor)
            
            ctx.fill(CGRect(origin: CGPoint.zero, size: frame.size))
        }
        
        /// stroke line
        
        ctx.beginPath()
        
        ctx.setStrokeColor(strokeColor.cgColor)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        ctx.setLineWidth(lineWidth)
        
        /// check is line dash
        if isLineDash {
            ctx.setLineDash(phase: 0, lengths: Array(repeatElement(lineDash, count: 20)))
        }
        
        /// check which border to draw
        
        let borderSet = BorderNumber(rawValue: borderNumber)
        
        if borderSet.contains(.top) {
            ctx.move(to: frame.topLeft)
            ctx.addLine(to: frame.topRight)
        }
        if borderSet.contains(.left) {
            ctx.move(to: frame.topLeft)
            ctx.addLine(to: frame.bottomLeft)
        }
        if borderSet.contains(.right) {
            ctx.move(to: frame.topRight)
            ctx.addLine(to: frame.bottomRight)
        }
        if borderSet.contains(.bottom) {
            ctx.move(to: frame.bottomLeft)
            ctx.addLine(to: frame.bottomRight)
        }
        
        ctx.strokePath()
    }
    
}
