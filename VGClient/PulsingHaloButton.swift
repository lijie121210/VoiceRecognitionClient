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
    
    @IBInspectable var count: Int = 1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        startPulsing(number: count, duration: duration, color: color)
    }
    
    func pulsing() {
        
        removePulsing()
        
        startPulsing(number: count, duration: duration, color: color)
    }
}
