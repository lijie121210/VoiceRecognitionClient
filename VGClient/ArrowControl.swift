//
//  ArrowControl.swift
//  VGClient
//
//  Created by jie on 2017/3/10.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

/// Returns a Boolean value indicating whether two values are equal.
///
/// Equality is the inverse of inequality. For any values `a` and `b`,
/// `a == b` implies that `a != b` is `false`.
///
/// - Parameters:
///   - lhs: A value to compare.
///   - rhs: Another value to compare.
public func ==(lhs: VGLine, rhs: VGLine) -> Bool {
    return lhs.p2 == rhs.p2 && lhs.p1 == rhs.p1
}

public func ==(lhs: XLine, rhs: XLine) -> Bool {
    return lhs.bottom == rhs.bottom && lhs.top == rhs.top
}

public func ==(lhs: ArrowPoint, rhs: ArrowPoint) -> Bool {
    return
        lhs.vertex == rhs.vertex &&
        lhs.leftEndPoint == rhs.rightEndPoint &&
        lhs.rightEndPoint == rhs.rightEndPoint
}



/// 父类，定义几个变量
///
@IBDesignable open class LineControl: UIControl {
    
    @IBInspectable open var fillColor: UIColor = .white
    
    @IBInspectable open var strokeColor: UIColor = .black
    
    @IBInspectable open var lineWidth: CGFloat = 2.0
    
    
    /// 阴影的属性
    @IBInspectable open var isShadow: Bool = false
    
    @IBInspectable open var shadowColor: UIColor = UIColor.darkGray.withAlphaComponent(0.6)
    
    @IBInspectable open var shadowBlur: CGFloat = 2.0
    
    @IBInspectable open var xShadow: CGFloat = 0
    
    @IBInspectable open var yShadow: CGFloat = -1
    
    
    /// 调整区域的大小
    @IBInspectable open var radius: CGFloat = 15.0
    
    
    /// 调整线段的长度
    @IBInspectable open var offset: CGFloat = 10.0
    
    
    
    
    /// 检查尺寸设置
    open var isFrameValide: Bool {
        
        return frame.size.width >= radius * 2 && frame.size.height >= radius * 2
    }
    
    
    /// 背景区域
    open var aera: CGRect {
        
        return CGRect(x: frame.size.width * 0.5 - 1, y: frame.size.height * 0.5 - 1, width: 2, height: 2)
            .insetBy(dx: -radius, dy: -radius)
    }
    
    
    
    
    /// 绘制背景圆
    open func drawAera(_ ctx: CGContext, rect: CGRect) {
       
        ctx.beginPath()
        
        ctx.setFillColor(fillColor.cgColor)
        
        if isShadow {
            ctx.setShadow(offset: CGSize(width:xShadow, height: yShadow), blur: shadowBlur, color: shadowColor.cgColor)
        }
        
        ctx.addPath(UIBezierPath(roundedRect: rect, cornerRadius: rect.width * 0.5).cgPath)
        
        ctx.fillPath()
        
        ctx.saveGState()
    }
}





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
    
    /// 顺时针第二个点
    var vertex: CGPoint
    
    /// 顺时针第一个点
    var leftEndPoint: CGPoint
    
    /// 顺时针第三个点
    var rightEndPoint: CGPoint
    
    /// - distance： 顶点相对中心的偏移
    /// - offset： 端点相对中心的偏移
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
            
        case .right:
            
            vertex = CGPoint(x: cx0 + d, y: cy0)
            leftEndPoint = CGPoint(x: cx0 - d, y: cy0 - f)
            rightEndPoint = CGPoint(x: cx0 - d, y: cy0 + f)
            
        case .left:
            
            vertex = CGPoint(x: cx0 - d, y: cy0)
            leftEndPoint = CGPoint(x: cx0 + d, y: cy0 + f)
            rightEndPoint = CGPoint(x: cx0 + d, y: cy0 - f)
            
        default:
            
            vertex = CGPoint(x: cx0, y: cy0 + d)
            leftEndPoint = CGPoint(x: cx0 - f, y: cy0 - d)
            rightEndPoint = CGPoint(x: cx0 + f, y: cy0 - d)
            
        }
    }
}



/// 绘制箭头
///
@IBDesignable open class ArrowControl: LineControl {
    
    /// 调整线段的长度
    @IBInspectable open var distance: CGFloat = 8.0
    
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
        
        guard isFrameValide, let ctx = UIGraphicsGetCurrentContext() else {
            
            return print(self, #function, "invlaid frame")
        }
        
        /// 计算绘制箭头的区域
        let r = aera

        /// 绘制背景圆
        drawAera(ctx, rect: r)
        
        
        /// 计算箭头的点
        let arrowPoint = ArrowPoint(direction: _direction, distance: distance, offset: offset, frame: r)
        
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





public struct VGLine: Equatable {
    
    public var p1: CGPoint
    public var p2: CGPoint
}



public struct XLine: Equatable {
    
    
    var top: VGLine
    
    var bottom: VGLine
    
    init(frame: CGRect, offset: CGFloat) {
        
        let x0 = frame.origin.x
        let y0 = frame.origin.y
        let w = frame.size.width
        let h = frame.size.height
        let cx0 = x0 + w * 0.5
        let cy0 = y0 + h * 0.5
        
        /// top left -> bottom right
        top = VGLine(p1: CGPoint(x: cx0 - offset, y: cy0 - offset), p2: CGPoint(x: cx0 + offset, y: cy0 + offset))
        
        /// bottom left -> top right
        bottom = VGLine(p1: CGPoint(x: cx0 - offset, y: cy0 + offset), p2: CGPoint(x: cx0 + offset, y: cy0 - offset))
    }    
}


/// 绘制 X
///
@IBDesignable open class XControl: LineControl {
    
    open override func draw(_ rect: CGRect) {
        
        guard isFrameValide, let ctx = UIGraphicsGetCurrentContext() else {
            
            return print(self, #function, "invlaid frame")
        }
        
        /// 计算绘制箭头的区域
        let r = aera
        
        /// 绘制背景圆
        drawAera(ctx, rect: r)
        
        let xline = XLine(frame: r, offset: offset)
        
        /// 绘制 X
        ctx.beginPath()
        ctx.setStrokeColor(strokeColor.cgColor)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        ctx.setLineWidth(lineWidth)
        ctx.move(to: xline.top.p1)
        ctx.addLine(to: xline.top.p2)
        ctx.move(to: xline.bottom.p1)
        ctx.addLine(to: xline.bottom.p2)
        ctx.strokePath()
    }
}



extension XLine {
    
    /// 对号✅ 的三个点
    init(frame: CGRect, x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat, x3: CGFloat, y3: CGFloat) {
        
        let x0 = frame.origin.x
        let y0 = frame.origin.y
        let w = frame.size.width
        let h = frame.size.height
        let cx0 = x0 + w * 0.5
        let cy0 = y0 + h * 0.5
        
        top = VGLine(p1: CGPoint(x: cx0+x1, y: cy0+y1), p2: CGPoint(x: cx0+x2, y: cy0+y2))
        
        bottom = VGLine(p1: CGPoint(x: cx0+x2, y: cy0+y2), p2: CGPoint(x: cx0+x3, y: cy0+y3))
    }
}




/// 绘制 ✅
///
@IBDesignable open class HookControl: LineControl {
    
    
    @IBInspectable open var x1: CGFloat = -10.0
    @IBInspectable open var y1: CGFloat = 0.0
    
    @IBInspectable open var x2: CGFloat = -5.0
    @IBInspectable open var y2: CGFloat = 5.0
    
    @IBInspectable open var x3: CGFloat = 10.0
    @IBInspectable open var y3: CGFloat = -10.0

    
    open override func draw(_ rect: CGRect) {
        
        guard isFrameValide, let ctx = UIGraphicsGetCurrentContext() else {
            
            return print(self, #function, "invlaid frame")
        }
        
        /// 计算绘制箭头的区域
        let r = aera
        
        /// 绘制背景圆
        drawAera(ctx, rect: r)
        
        
        let hookLine = XLine(frame: r, x1: x1, y1: y1, x2: x2, y2: y2, x3: x3, y3: y3)
        
        /// 绘制 ✅
        ctx.beginPath()
        ctx.setStrokeColor(strokeColor.cgColor)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        ctx.setLineWidth(lineWidth)
        ctx.move(to: hookLine.top.p1)
        ctx.addLine(to: hookLine.top.p2)
        ctx.addLine(to: hookLine.bottom.p2)
        ctx.strokePath()
    }
}
