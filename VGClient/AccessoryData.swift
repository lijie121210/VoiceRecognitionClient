//
//  AccessoryData.swift
//  VGClient
//
//  Created by jie on 2017/3/11.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit
import Foundation

/// 名称应是唯一的，其他项其实没有必要比较。
///
func ==(lhs: AccessoryData, rhs: AccessoryData) -> Bool {
    return lhs.name == rhs.name && lhs.type == rhs.type
}

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
struct AccessoryData: Equatable {
    
    let type: AccessoryType
    
    var state: AccessoryStatus

    var name: String
    
    var isTimed: Bool = false
    
    var image: UIImage? {
        return UIImage(named: type.icon)
    }

    init(type: AccessoryType, state: AccessoryStatus, name: String? = nil) {
        self.type = type
        self.name = name ?? type.name
        self.state = state
    }
}










