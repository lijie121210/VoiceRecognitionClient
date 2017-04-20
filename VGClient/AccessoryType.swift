//
//  AccessoryType.swift
//  VGClient
//
//  Created by viwii on 2017/4/16.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UIKit


/// Returns a Boolean value indicating whether two values are equal.
///
/// Equality is the inverse of inequality. For any values `a` and `b`,
/// `a == b` implies that `a != b` is `false`.
///
/// - Parameters:
///   - lhs: A value to compare.
///   - rhs: Another value to compare.
func ==(lhs: AccessoryAction, rhs: AccessoryAction) -> Bool {
    
    switch (lhs, rhs) {
        
    case (.open, .open), (.close, .close), (.stop, .stop): return true
        
    case let (.timing(a), .timing(b)): return a == b
        
    default: return false
    }
}


/// 附件类型
///
enum AccessoryType: Int, Equatable {
    /// 卷帘机 curtain
    case rollingMachine
    /// 浇灌泵
    case wateringPump
    /// 通风机
    case ventilator
    /// 增温灯
    case warmingLamp
    /// 补光灯
    case fillLight
}

/// 增加一个默认名称
///
extension AccessoryType {
    
    var name: String {
        switch self {
        case .rollingMachine: return "卷帘机"
        case .wateringPump: return "浇灌泵"
        case .ventilator: return "通风机"
        case .warmingLamp: return "增温灯"
        case .fillLight: return "补光灯"
        }
    }
    
    init?(name: String) {
        switch name {
        case "卷帘机": self = AccessoryType.rollingMachine
        case "浇灌泵": self = AccessoryType.wateringPump
        case "通风机": self = AccessoryType.ventilator
        case "增温灯": self = AccessoryType.warmingLamp
        case "补光灯": self = AccessoryType.fillLight
        default: return nil
        }
        
    }
}


/// 附件类型的简单分类
///
extension AccessoryType {
    
    /// 这些设备的操作都是简单的 【 开 | 关 】
    static var singleActionTypes:[AccessoryType] {
        return [.ventilator, .warmingLamp, .fillLight, .wateringPump]
    }
    
    /// 这些设备的操作则稍微复杂
    static var multipleActionTypes: [AccessoryType] {
        return [.rollingMachine]
    }
    
    var isSingleActionTypes: Bool {
        return AccessoryType.singleActionTypes.contains(self)
    }
}

/// 通过类型直接或得类型图标
///
extension AccessoryType {
    
    var icon: String {
        return "\(self)"
    }
}



/// 附件状态
///
enum AccessoryStatus: Int {
    
    case unknown
    
    case closed
    
    case opened
    
    case stopped
}

extension AccessoryStatus {
    
    var textDescription: String {
        switch self {
        case .unknown: return "未知"
        case .closed: return "关闭"
        case .opened: return "打开"
        case .stopped: return "停止"
        }
    }
}





/// 附件操作
///
enum AccessoryAction: Equatable {
    
    case close
    
    case stop
    
    case open
    
    case timing(TimeInterval)
}

