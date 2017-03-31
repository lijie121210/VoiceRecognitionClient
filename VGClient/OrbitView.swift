//
//  OrbitView.swift
//  Orbit
//
//  Created by jie on 2016/12/7.
//  Copyright © 2016年 HuatengIOT. All rights reserved.
//

import UIKit


extension CABasicAnimation {
    
    convenience init(keyPath: String, from: CGFloat, to: CGFloat,
                            repeatCount: Float,
                            duration: CFTimeInterval,
                            timingFunction name: String,
                            autoreverses: Bool) {
        
        self.init(keyPath: keyPath)
        self.fromValue = from
        self.toValue = to
        self.repeatCount = repeatCount
        self.duration = duration
        self.autoreverses = autoreverses
        self.timingFunction = CAMediaTimingFunction(name: name)
    }
    
}

class OrbitView: UIView {
    
}

extension OrbitView {
    
    enum AnimKey: String {
        
        enum rotation: String {
            case x = "transform.rotation.x"
            case y = "transform.rotation.y"
            case z = "transform.rotation.z"
        }
        
        case strokeStart = "strokeStart"
        
        case strokeEnd = "strokeEnd"
        
        case position = "position"
    }
    
    struct Tailor {
        
        var baseSize: CGSize
        
        var shortLength: CGFloat {
            return min(baseSize.height, baseSize.width)
        }
        
        /// 计算背景圆参数
        var radiusOfCircle: CGFloat {
            return shortLength.divided(by: 4.0)
        }
        var xdistanceOfCircle: CGFloat {
            return (baseSize.width - radiusOfCircle * 2.0).divided(by: 2.0)
        }
        var ydistanceOfCircle: CGFloat {
            return (baseSize.height - radiusOfCircle * 2).divided(by: 2.0)
        }
        var widthOfCircle: CGFloat {
            return radiusOfCircle.multiplied(by: 2.0)
        }
        
        /// 计算环参数
        var spaceToRing: CGFloat {
            return radiusOfCircle * 0.2
        }
        var widthOfRing: CGFloat {
            return (radiusOfCircle + spaceToRing).multiplied(by: 2.0)
        }
        var xdistanceOfRing: CGFloat {
            return (baseSize.width - widthOfRing).divided(by: 2.0)
        }
        var ydistanceOfRing: CGFloat {
            return (baseSize.height - widthOfRing).divided(by: 2.0)
        }
        
        /// 计算点参数
        var spaceToStar: CGFloat {
            return radiusOfCircle - 1
        }
        var widthOfStar: CGFloat {
            return (radiusOfCircle + spaceToStar).multiplied(by: 2.0)
        }
        var xdistanceOfStar: CGFloat {
            return (baseSize.width - widthOfStar).divided(by: 2.0)
        }
        var ydistanceOfStar: CGFloat {
            return (baseSize.height - widthOfStar).divided(by: 2.0)
        }
        
        
        init(baseSize: CGSize) {
            
            self.baseSize = baseSize
            
            if baseSize.width < 60.0 || baseSize.height < 60.0 {
                print(self, #function, "maybe frame is too small")
            }
        }
        
    }
    
    /// 创建基础动画
    func animation(keyPath: String, from: CGFloat, to: CGFloat, repeatCount: Float, duration: CFTimeInterval,
                   timingFunction name: String, autoreverses: Bool) -> CABasicAnimation {
        
        return CABasicAnimation(keyPath: keyPath, from: from, to: to,
                                repeatCount: repeatCount,duration: duration, timingFunction: name, autoreverses: autoreverses)
    }
    
    /// 透视效果
    func perspective(on view: UIView, with value: CGFloat = 0.003) {
        var t = CATransform3DIdentity
        t.m34 = value
        view.layer.sublayerTransform = t
    }
    
    /// 月牙阴影
    func crescentShapeLayer(radius: CGFloat, fillColor: UIColor = UIColor(white: 0.96, alpha: 1)) -> CAShapeLayer {
        
        let path = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius),
                                  radius: radius - 2.0,
                                  startAngle: CGFloat.pi.divided(by: -2.0),
                                  endAngle: CGFloat.pi.divided(by: 2.0),
                                  clockwise: true)
        
        let tpoint = CGPoint(x: radius, y: 2)
        path.addCurve(to: tpoint, controlPoint1: CGPoint(x: radius * 1.8, y: radius), controlPoint2: tpoint)
        path.close()
        
        let crescent = CAShapeLayer()
        crescent.path = path.cgPath
        crescent.fillRule = kCAFillRuleNonZero
        crescent.fillMode = kCAFillModeForwards
        crescent.fillColor = fillColor.cgColor
        
        return crescent
    }
    
    func backgroundCircle(tailor: Tailor) -> UIView {
        let vi = UIView(frame: CGRect(x: tailor.xdistanceOfCircle,
                                      y: tailor.ydistanceOfCircle,
                                      width: tailor.widthOfCircle,
                                      height: tailor.widthOfCircle))
        vi.backgroundColor = UIColor(white: 0.99, alpha: 1)
        vi.layer.cornerRadius = tailor.radiusOfCircle
        vi.layer.borderColor = UIColor.black.cgColor
        vi.layer.borderWidth = 2.0
        return vi
    }
    
    func ring(tailor: Tailor) -> UIView {
        let width = tailor.widthOfRing
        let ring = UIView(frame: CGRect(x: tailor.xdistanceOfRing, y: tailor.ydistanceOfRing, width: width, height: width))
        ring.layer.cornerRadius = width.divided(by: 2.0)
        ring.layer.borderColor = UIColor.black.cgColor
        ring.layer.borderWidth = 1.0
        return ring
    }
    
    func star(tailor: Tailor) -> UIView {
        let width = tailor.widthOfStar
        let star = UIView(frame: CGRect(x: tailor.xdistanceOfStar, y: tailor.ydistanceOfStar, width: width, height: width))
        star.layer.cornerRadius = width.divided(by: 2.0)
        return star
    }
    
    func point(width: CGFloat = 2.0, withAnimation animation: CAKeyframeAnimation, animationkey: String) -> UIView {
        let p = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width)))
        p.layer.cornerRadius = width.divided(by: 2.0)
        p.backgroundColor = .black
        p.layer.add(animation, forKey: animationkey)
        return p
    }
    
    func positionAnimation(for rect: CGRect, duration: CFTimeInterval) -> CAKeyframeAnimation {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: rect.width * 0.5)
        let an = CAKeyframeAnimation(keyPath: AnimKey.position.rawValue)
        an.path = path.cgPath
        an.rotationMode = kCAAnimationRotateAuto
        an.calculationMode = kCAAnimationPaced
        an.duration = duration
        an.repeatCount = Float.greatestFiniteMagnitude
        return an
    }
    
    func createStarPath(size: CGSize) -> CGPath {
        let numberOfPoints: CGFloat = 5
        
        let starRatio: CGFloat = 0.5
        
        let steps: CGFloat = numberOfPoints * 2
        
        let outerRadius: CGFloat = min(size.height, size.width) / 2
        let innerRadius: CGFloat = outerRadius * starRatio
        
        let stepAngle = CGFloat(2) * CGFloat.pi / CGFloat(steps)
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        
        let path = CGMutablePath()
        
        for i in 0..<Int(steps) {
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            
            let angle = CGFloat(i) * stepAngle - CGFloat.pi / 2.0
            
            let x = radius * cos(angle) + center.x
            let y = radius * sin(angle) + center.y
            
            let point = CGPoint(x: x, y: y)
            
            if i == 0 {
                path.move(to: point)
            }
            else {
                path.addLine(to: point)
            }
        }
        
        path.closeSubpath()

        return path
    }
    
    
    var xrotationForHorizontalRing: CABasicAnimation {
        return CABasicAnimation(keyPath: AnimKey.rotation.x.rawValue,
                                from: CGFloat.pi.divided(by: 2.0), to: CGFloat.pi.divided(by: -2.0),
                                repeatCount: Float.greatestFiniteMagnitude, duration: 6.0,
                                timingFunction: kCAMediaTimingFunctionLinear, autoreverses: false)
    }
    
    var zrotationForHorizontalRing: CABasicAnimation {
        return CABasicAnimation(keyPath: AnimKey.rotation.z.rawValue,
                                from: CGFloat.pi.divided(by: -6.0),
                                to: CGFloat.pi.divided(by: 6.0),
                                repeatCount: Float.greatestFiniteMagnitude,
                                duration: 6.0, timingFunction: kCAMediaTimingFunctionLinear, autoreverses: true)
    }
    
    var yrotationForVerticalRing: CABasicAnimation {
        return CABasicAnimation(keyPath: AnimKey.rotation.y.rawValue,
                                from: CGFloat.pi.multiplied(by: 3.0).divided(by: 8.0),
                                to: CGFloat.pi.multiplied(by: 5.0).divided(by: 8.0),
                                repeatCount: Float.greatestFiniteMagnitude,duration: 4.0,
                                timingFunction: kCAMediaTimingFunctionEaseInEaseOut,autoreverses: true)
    }
    
    var zrotationForVerticalRing: CABasicAnimation {
        return animation(keyPath: AnimKey.rotation.z.rawValue,
                         from: CGFloat.pi.divided(by: -12.0),
                         to: CGFloat.pi.divided(by: 12.0),
                         repeatCount: Float.greatestFiniteMagnitude,
                         duration: 4.0,
                         timingFunction: kCAMediaTimingFunctionEaseInEaseOut,
                         autoreverses: true)
    }
    
    var zrotationForPointContainer: CABasicAnimation {
        return animation(keyPath: AnimKey.rotation.z.rawValue,
                         from: 0.0, to: CGFloat.pi.multiplied(by: 2.0),
                         repeatCount: Float.greatestFiniteMagnitude,
                         duration: 10.0,
                         timingFunction: kCAMediaTimingFunctionLinear,
                         autoreverses: false)
    }
    
    var zrotationForPointContainer2: CABasicAnimation {
        return animation(keyPath: AnimKey.rotation.z.rawValue,
                         from: 0.0, to: CGFloat.pi.multiplied(by: 2.0),
                         repeatCount: Float.greatestFiniteMagnitude,
                         duration: 10.0,
                         timingFunction: kCAMediaTimingFunctionEaseInEaseOut,
                         autoreverses: false)
    }
    
    var xrotationForPointContainer: CABasicAnimation {
        return animation(keyPath: AnimKey.rotation.x.rawValue,
                         from: CGFloat.pi.divided(by: 4.0).multiplied(by: 1.6).adding(-0.0001),
                         to: CGFloat.pi.divided(by: 4.0).multiplied(by: 1.6).adding(0.0001),
                         repeatCount: Float.greatestFiniteMagnitude,
                         duration: 8.0,
                         timingFunction: kCAMediaTimingFunctionLinear,
                         autoreverses: true)
    }
    
    var yrotationForPointContainer: CABasicAnimation {
        return animation(keyPath: AnimKey.rotation.y.rawValue,
                         from: CGFloat.pi.divided(by: 4.0).multiplied(by: 1.6).adding(-0.0001),
                         to: CGFloat.pi.divided(by: 4.0).multiplied(by: 1.6).adding(0.0001),
                         repeatCount: Float.greatestFiniteMagnitude,
                         duration: 8.0,
                         timingFunction: kCAMediaTimingFunctionLinear,
                         autoreverses: true)
    }
    
    func launchOrbit() {
    
        let view = self
        
        perspective(on: self)
        
        let tailor = Tailor(baseSize: frame.size)
        
        /// 创建两个200x200的矩形，并剪裁成圆, 
        /// 背景圆
        
        let crescent = crescentShapeLayer(radius: tailor.radiusOfCircle)
        let vi = backgroundCircle(tailor: tailor)
        vi.layer.addSublayer(crescent)
        view.addSubview(vi)
        
        /// 创建两个大环的父视图
        let horizontalRing = ring(tailor: tailor)
        let vertivalRing = ring(tailor: tailor)
        
        horizontalRing.layer.add(xrotationForHorizontalRing, forKey: "xrotationForHorizontalRing")
        horizontalRing.layer.add(zrotationForHorizontalRing, forKey: "zrotationForHorizontalRing")
        
        vertivalRing.layer.add(yrotationForVerticalRing, forKey: "yrotationForVerticalRing")
        vertivalRing.layer.add(zrotationForVerticalRing, forKey: "zrotationForVerticalRing")
        
        view.addSubview(horizontalRing)
        view.addSubview(vertivalRing)
        
        /// 创建两个点的父视图
        let pointContainer1 = star(tailor: tailor)
        let pointContainer2 = star(tailor: tailor)

        view.addSubview(pointContainer1)
        view.addSubview(pointContainer2)
        
        /// 创建一个点        
        let an1 = positionAnimation(for: pointContainer1.bounds.insetBy(dx: 4, dy: 4), duration: 3.0)
        let an2 = positionAnimation(for: pointContainer2.bounds.insetBy(dx: 4, dy: 4), duration: 2.0)
        
        pointContainer1.addSubview(point(width: 4, withAnimation: an1, animationkey: "point1"))
        pointContainer2.addSubview(point(width: 4, withAnimation: an2, animationkey: "point2"))
        
        pointContainer1.layer.add(zrotationForPointContainer, forKey: "zrotationForPointContainer")
        pointContainer1.layer.add(xrotationForPointContainer, forKey: "xrotationForPointContainer")
        pointContainer2.layer.add(yrotationForPointContainer, forKey: "yrotationForPointContainer")
        pointContainer2.layer.add(zrotationForPointContainer2, forKey: "zrotationForPointContainer2")
        
    }
    
    
}
