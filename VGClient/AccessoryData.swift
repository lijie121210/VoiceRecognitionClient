//
//  AccessoryData.swift
//  VGClient
//
//  Created by jie on 2017/3/11.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit
import Foundation

/// 附件状态
///
public enum AccessoryStatus: Int {
    
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


/// 附件类型
///
public enum AccessoryType: Int, Equatable {
    
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
}


/// 附件类型的简单分类
///
public extension AccessoryType {
    
    /// 这些设备的操作都是简单的 【 开 | 关 】
    
    public static var singleActionTypes:[AccessoryType] {
        
        return [.ventilator, .warmingLamp, .fillLight]
    }
    
    /// 这些设备的操作则稍微复杂
    
    public static var multipleActionTypes: [AccessoryType] {
        
        return [.rollingMachine, .wateringPump]
    }
    
    public var isSingleActionTypes: Bool {
        
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


/// 附件操作
///
public enum AccessoryAction: Equatable {
    
    case close
    
    case stop
    
    case open
    
    case timing(TimeInterval)
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







