//
//  MonitorInfoData.swift
//  VGClient
//
//  Created by jie on 2017/3/11.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit
//import Foundation


/// 监测信息的单位

public enum MeasurementUnit: String, Equatable {
    
    /// 温度
    case temperature = "°C"
    
    /// 湿度
    case humidity = "% RH"
    
    /// 强度
    case intensity = "lx"
    
    /// 浓度
    case concentration = "ppm"
    
    /// 空
    case none = ""
}


/// 监测信息种类

public enum MeasurementType: Int, Equatable {
    
    /// 空气温度
    case airTemperature
    
    /// 空气湿度
    case airHumidity
    
    /// 土壤温度
    case soilTemperature
    
    /// 土壤湿度
    case soilHumidity
    
    /// 光照强度
    case lightIntensity
    
    /// CO2浓度
    case co2Concentration
    
    /// 综合
    case integrated
}

/// 文字描述
///
extension MeasurementType {
    
    var textDescription: String {
        switch self {
        case .airHumidity:      return "空气湿度"
        case .airTemperature:   return "空气温度"
        case .soilHumidity:     return "土壤湿度"
        case .soilTemperature:  return "土壤温度"
        case .co2Concentration: return "CO2浓度"
        case .lightIntensity:   return "光照强度"
        case .integrated:       return "综合"
        }
    }
    
    init?(textDescription: String) {
        switch textDescription {
        case "空气湿度": self = MeasurementType.airHumidity
        case "空气温度": self = MeasurementType.airTemperature
        case "土壤湿度": self = MeasurementType.soilHumidity
        case "土壤温度": self = MeasurementType.soilTemperature
        case "CO2浓度": self = MeasurementType.co2Concentration
        case "光照强度": self = MeasurementType.lightIntensity
        case "综合": self = MeasurementType.integrated
        default: return nil
        }
    }
}

/// 使用监测信息种类可以直接获得单位
///
extension MeasurementType {
    
    var unit: MeasurementUnit {
        switch self {
        case .airTemperature, .soilTemperature: return .temperature
        case .airHumidity, .soilHumidity: return .humidity
        case .lightIntensity: return .intensity
        case .co2Concentration: return .concentration
        case .integrated: return .none
        }
    }
}

/// 使用监测信息种类可以直接获得图标
///
extension MeasurementType {
    
    var icon: String {
        
        /// 当作备用图标吧
        if self == .integrated {
            
            return "blinkmic"
        }
        
        return "\(self)"
    }
}

/// 监控信息数据结构
///
public struct MeasurementData {
    
    let itemType: MeasurementType
    
    var itemUnit: MeasurementUnit { return itemType.unit }
    
    var itemImage: UIImage? { return UIImage(named: itemType.icon) }

    var value: Float
    
    var updateDate: String
    
}

