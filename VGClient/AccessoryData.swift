//
//  AccessoryData.swift
//  VGClient
//
//  Created by jie on 2017/3/11.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit
import Foundation


public struct PickerTitle {
    
    public var leftTitles: [String]
    
    public var rightTitles: [String]
    
}

public struct AccessoryPicker {
    
    public var title: PickerTitle
    
    public let count = 2
    
    init() {
        
        var left = [String]()
        for i in 1...60 {
            left.append("\(i)号")
        }
        
        var right = [String]()
        for i in 0..<5 {
            right.append(AccessoryType(rawValue: i)!.name)
        }
        
        title = PickerTitle(leftTitles: left, rightTitles: right)
    }
}




/// 一个附件的数据结构
public struct AccessoryData {
    
    public let type: AccessoryType
    
    public var state: AccessoryStatus

    public var name: String
    
    public var image: UIImage? { return UIImage(named: type.icon) }

    public init(type: AccessoryType, state: AccessoryStatus, name: String? = nil) {
        self.type = type
        self.name = name ?? type.name
        self.state = state
    }
}



/// Returns a Boolean value indicating whether two values are equal.
///
/// Equality is the inverse of inequality. For any values `a` and `b`,
/// `a == b` implies that `a != b` is `false`.
///
/// - Parameters:
///   - lhs: A value to compare.
///   - rhs: Another value to compare.
public func ==(lhs: AccessoryAction, rhs: AccessoryAction) -> Bool {
    
    switch (lhs, rhs) {
        
    case (.open, .open), (.close, .close), (.stop, .stop): return true
        
    case let (.timing(a), .timing(b)): return a == b
        
    default: return false
    }
}







