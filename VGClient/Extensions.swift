//
//  Extensions.swift
//  VGClient
//
//  Created by jie on 2017/2/19.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation

/******************************** Audio text ***********************************/


/// Create a file name from current date

extension Date {
    
    static var currentName: String {
        
        let formatterString = DateFormatter.localizedString(from: Date(),
                                                            dateStyle: .short,
                                                            timeStyle: .long)
        
        let res = formatterString.replacingOccurrences(of: " ", with: "a")
            .replacingOccurrences(of: "/", with: "b")
            .replacingOccurrences(of: "+", with: "c")
            .replacingOccurrences(of: ":", with: "d")
            .replacingOccurrences(of: ",", with: "e")
        
        return res
    }
    
    var recordDescription: String {
        
        return DateFormatter.localizedString(from: self,
                                             dateStyle: .long,
                                             timeStyle: .long)
            .replacingOccurrences(of: "GMT+8", with: "")
    }
}


extension TimeInterval {
    
    /// 用迭代重写!
    
    func dateDescription() -> String {
        
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
    
}
