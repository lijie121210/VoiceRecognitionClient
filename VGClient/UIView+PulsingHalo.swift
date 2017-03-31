//
//  UIButton+PulsingHalo.swift
//  VGClient
//
//  Created by viwii on 2017/3/28.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit
import PulsingHalo


extension UIView {
    
    var isPulsed: Bool {
        
        guard let sublayers = layer.sublayers else {
            return false
        }
        
        return !sublayers.filter { $0 is PulsingHaloLayer }.isEmpty
    }
    
    var haloLayerNumber: Int? {
        get {
            guard let sublayers = layer.sublayers else {
                return nil
            }
            
            let player = sublayers.filter { $0 is PulsingHaloLayer }.first
            
            guard let pulsingLayer = player as? PulsingHaloLayer else {
                return nil
            }
            
            return pulsingLayer.haloLayerNumber
        }
        set {
            guard let sublayers = layer.sublayers else {
                return
            }
            
            let player = sublayers.filter { $0 is PulsingHaloLayer }.first
            
            guard let pulsingLayer = player as? PulsingHaloLayer else {
                return
            }
            
            pulsingLayer.haloLayerNumber = newValue ?? 0
        }
    }
    
    
    var haloAnimationDuration: TimeInterval? {
        get {
            guard let sublayers = layer.sublayers else {
                return nil
            }
            
            let player = sublayers.filter { $0 is PulsingHaloLayer }.first
            
            guard let pulsingLayer = player as? PulsingHaloLayer else {
                return nil
            }
            
            return pulsingLayer.animationDuration
        }
        set {
            guard let sublayers = layer.sublayers else {
                return
            }
            
            let player = sublayers.filter { $0 is PulsingHaloLayer }.first
            
            guard let pulsingLayer = player as? PulsingHaloLayer else {
                return
            }
            
            pulsingLayer.animationDuration = newValue ?? 0
        }
    }
    
    var haloShadowColor: CGColor? {
        get {
            guard let sublayers = layer.sublayers else {
                return nil
            }
            
            let player = sublayers.filter { $0 is PulsingHaloLayer }.first
            
            guard let pulsingLayer = player as? PulsingHaloLayer else {
                return nil
            }
            
            return pulsingLayer.shadowColor
        }
        set {
            guard let sublayers = layer.sublayers else {
                return
            }
            
            let player = sublayers.filter { $0 is PulsingHaloLayer }.first
            
            guard let pulsingLayer = player as? PulsingHaloLayer else {
                return
            }
            
            pulsingLayer.shadowColor = newValue
        }
    }
    
    /// 添加动画图层
    func startPulsing(number: Int, duration: TimeInterval, color: UIColor?) {
        
        if isPulsed {
            return
        }
        
        let halo = PulsingHaloLayer()
        
        halo.position = CGPoint(x: frame.width * 0.5, y: frame.height * 0.5)
        
        halo.haloLayerNumber = number
        
        halo.animationDuration = duration
        
        if let c = color {
            halo.shadowColor = c.cgColor
        }
        
        layer.addSublayer(halo)
        
        halo.start()
    }
    
    /// 找到这个图层，删除
    func removePulsing() {
        
        guard let sublayers = layer.sublayers else {
            return
        }
        for lay in sublayers where lay is PulsingHaloLayer {
            lay.removeFromSuperlayer()
        }
    }
}
