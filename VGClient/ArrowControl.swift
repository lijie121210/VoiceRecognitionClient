//
//  ArrowControl.swift
//  VGClient
//
//  Created by jie on 2017/3/10.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit


public enum ArrowDirection: Int {
    
    case left   = 1
    case right  = 2
    case top    = 3
    case bottom = 4
    
    case lefttop        = 5
    case righttop       = 6
    case leftbottom     = 7
    case rightbottom    = 8
}

/// 计算箭头的三个点；
public struct ArrowPoint: Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: ArrowPoint, rhs: ArrowPoint) -> Bool {
        return
            lhs.vertex == rhs.vertex &&
            lhs.leftEndPoint == rhs.rightEndPoint &&
            lhs.rightEndPoint == rhs.rightEndPoint
    }

    
    var vertex: CGPoint
    var leftEndPoint: CGPoint
    var rightEndPoint: CGPoint
    
    /// - divisor： 由于没有做divisor的校验，需要校验后再穿入
    /// - size： 并没有做size的校验
    init(direction: ArrowDirection, distance: CGFloat, offset: CGFloat, frame: CGRect) {
        
        let x0 = frame.origin.x
        let y0 = frame.origin.y
        let w = frame.size.width
        let h = frame.size.height
        let cx0 = x0 + w * 0.5
        let cy0 = y0 + h * 0.5
        let d = distance
        let f = offset
        
        switch direction {
        case .bottom:
            
            vertex = CGPoint(x: cx0, y: cy0 + d)
            leftEndPoint = CGPoint(x: cx0 - f, y: cy0 - d)
            rightEndPoint = CGPoint(x: cx0 + f, y: cy0 - d)
            
        case .top:
            
            vertex = CGPoint(x: cx0, y: cy0 - d)
            leftEndPoint = CGPoint(x: cx0 - f, y: cy0 + d)
            rightEndPoint = CGPoint(x: cx0 + f, y: cy0 + d)
            
        default:
            
            vertex = CGPoint(x: cx0, y: cy0 + d)
            leftEndPoint = CGPoint(x: cx0 - f, y: cy0 - d)
            rightEndPoint = CGPoint(x: cx0 + f, y: cy0 - d)
            
        }
    }
}


@IBDesignable open class ArrowControl: UIControl {

    @IBInspectable public var fillColor: UIColor = .white
    
    @IBInspectable public var strokeColor: UIColor = .black
    
    @IBInspectable public var lineWidth: CGFloat = 2.0

    
    /// 在storyboard中设置ArrowDirection
    @IBInspectable public var direction: Int = ArrowDirection.bottom.rawValue
    
    /// 除数, 表示划分网格的份数，网格大小为 width  / (divisor + 1)
    @IBInspectable public var divisor: Int = 3
    
    /// 限定划分的比例大小
    public var _divisor: CGFloat {
        return max(1.0, min(CGFloat(divisor), 10.0))
    }
    
    public var _direction: ArrowDirection {
        
        /// 返回设置的值
        if let d = ArrowDirection(rawValue: direction) {
            return d
        }
        
        /// 返回默认值
        return .bottom
    }
    
    /// 从自身的大小中截取一个正方形，并使两个矩形中心重合，该正方形作为绘制箭头的画布
    public var drawRect: CGRect {
        
        let w = self.frame.size.width
        let h = self.frame.size.height
        
        if w == h {
            return frame
        } else if w > h {
            return CGRect(x: (w - h) * 0.5, y: 0, width: h, height: h)
        } else {
            return CGRect(x: 0, y: (h - w) * 0.5, width: w, height: w)
        }
    }
    
    override open func draw(_ rect: CGRect) {
        
        guard frame.size.width >= 30.0, frame.size.height >= 30.0 else {
            return print(self, #function, "invlaid frame")
        }
        
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        
        /// 计算绘制箭头的区域
        let r = CGRect(x: frame.size.width * 0.5 - 1, y: frame.size.height * 0.5 - 1, width: 2, height: 2).insetBy(dx: -15, dy: -15)

        /// 绘制背景圆
        ctx.beginPath()
        ctx.setFillColor(fillColor.cgColor)
        ctx.setShadow(offset: CGSize(width: 0, height: -1), blur: 2, color: UIColor.darkGray.withAlphaComponent(0.6).cgColor)
        ctx.addPath(UIBezierPath(roundedRect: r, cornerRadius: r.width * 0.5).cgPath)
        ctx.fillPath()
        
        
        /// 计算箭头的点
        let arrowPoint = ArrowPoint(direction: _direction, distance: 8, offset: 12, frame: r)
        
        /// 绘制箭头
        ctx.beginPath()
        ctx.setStrokeColor(strokeColor.cgColor)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        ctx.setLineWidth(lineWidth)
        ctx.addLines(between: [arrowPoint.leftEndPoint, arrowPoint.vertex, arrowPoint.rightEndPoint])
        ctx.strokePath()
        
    }

}
