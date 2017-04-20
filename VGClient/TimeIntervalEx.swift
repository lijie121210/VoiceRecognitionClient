//
//  TimeInterval+FormatDescription.swift
//  VGClient
//
//  Created by viwii on 2017/3/25.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation


/// A formatted output style to show audio data duration.
extension TimeInterval {
    
    /// 用迭代重写!
    
    var timeDescription: String {
        
        if self < 0 {
            return "--:--"
        }
        
        let _d: TimeInterval = 24 * 60 * 60
        let _h: TimeInterval = 60 * 60
        let _m: TimeInterval = 60
        let _s: TimeInterval = 1
        
        var res = ""
        
        var v = self
        
        var dx: Int = Int(v / _d)
        
        if dx >= 10 {
            res.append("\(dx)天 ")
        } else if dx > 0 {
            res.append("0\(dx)天 ")
        }
        
        /// handle hour
        
        v = v - TimeInterval(dx) * _d
        
        dx = Int(v / _h)
        
        if dx < 10 {
            res.append("0\(dx):")
        } else {
            res.append("\(dx):")
        }
        
        /// handle minute
        
        v = v - TimeInterval(dx) * _h
        
        dx = Int(v / _m)
        
        if dx < 10 {
            res.append("0\(dx):")
        } else {
            res.append("\(dx):")
        }
        
        /// handle second
        
        v = v - TimeInterval(dx) * _m
        
        dx = Int(v / _s)
        
        if dx < 10 {
            res.append("0\(dx)")
        } else {
            res.append("\(dx)")
        }
        
        return res
    }
    
    var minutesDescription: String {
        let des = timeDescription
        let e = des.index(des.endIndex, offsetBy: -5)
        return des.substring(from: e)
    }
    
}
