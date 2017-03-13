//
//  PulsingHaloButton.swift
//  VGClient
//
//  Created by jie on 2017/3/12.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit
import PulsingHalo

@IBDesignable class PulsingHaloButton: UIButton {
    
    @IBInspectable var color: UIColor?
    
    @IBInspectable var duration: TimeInterval = 3.0
    
    @IBInspectable var count: Int = 2
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pulsing()
    }
    
    var isPulsed: Bool {
        
        guard let sublayers = layer.sublayers else {
            return false
        }
        
        return !sublayers.filter { return $0 is PulsingHaloLayer }.isEmpty
    }
    
    /// 添加动画图层
    func pulsing() {
        
        if isPulsed {
            return
        }
        
        let halo = PulsingHaloLayer()
        
        halo.position = CGPoint(x: frame.width * 0.5, y: frame.height * 0.5)
        
        halo.haloLayerNumber = count
        
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
