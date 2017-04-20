//
//  MeasurementDataSource.swift
//  VGClient
//
//  Created by viwii on 2017/4/16.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UIKit


/// 负责解析从网络下载的数据，并分类存储，并提供读取接口
///
struct MeasurementDataSource {
    
    var airHumidity: [MeasurementData] = []
    
    var airTemperature: [MeasurementData] = []
    
    var soilHumidity: [MeasurementData] = []
    
    var soilTemperature: [MeasurementData] = []
    
    var co2Concentration: [MeasurementData] = []
    
    var lightIntensity: [MeasurementData] = []
    
    var integrated: [MeasurementData] {
        return airTemperature + airHumidity + soilTemperature + soilHumidity + co2Concentration + lightIntensity
    }
    
    /// 每个类型的最新数据
    var latest: [MeasurementData] {
        var res = [MeasurementData]()
        if let f = airTemperature.last {
            res.append(f)
        }
        if let f = airHumidity.last {
            res.append(f)
        }
        if let f = soilTemperature.last {
            res.append(f)
        }
        if let f = soilHumidity.last {
            res.append(f)
        }
        if let f = co2Concentration.last {
            res.append(f)
        }
        if let f = lightIntensity.last {
            res.append(f)
        }
        return res
    }
    
    
    init() { }
    
    init(from jsonData: Data) throws {
        let container = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        
        guard let jsonobj = container as? [String:Any] else {
            throw VGError.badParameter
        }
        
        for (key, value) in jsonobj {
            guard let type = MeasurementType(description: key), let array = value as? [Any] else {
                continue
            }
            var tmp = [MeasurementData]()
            array.forEach({ (item) in
                guard
                    let json = item as? [String:Any],
                    let time = json["time"] as? String,
                    let val = json["value"] as? Double else {
                        return
                }
                tmp.append(MeasurementData(itemType: type, value: val, updateDate: time))
            })
            tmp = tmp.sorted(by: { (a, b) -> Bool in
                do {
                    let at = try a.updateDate.dateTimeIntervalFrom1970()
                    let bt = try b.updateDate.dateTimeIntervalFrom1970()
                    return at <= bt
                } catch {
                    return true
                }
            })
            switch type {
            case .airTemperature:   airTemperature  = tmp
            case .airHumidity:      airHumidity     = tmp
            case .soilTemperature:  soilTemperature = tmp
            case .soilHumidity:     soilHumidity    = tmp
            case .co2Concentration: co2Concentration = tmp
            case .lightIntensity:   lightIntensity  = tmp
            default: break
            }
        }
    }
    
    init(airTemperature: [MeasurementData], airHumidity: [MeasurementData], soilTemperature: [MeasurementData], soilHumidity: [MeasurementData], co2Concentration: [MeasurementData], lightIntensity: [MeasurementData]) {
        self.airTemperature = airTemperature
        self.airHumidity = airHumidity
        self.soilTemperature = soilTemperature
        self.soilHumidity = soilHumidity
        self.co2Concentration = co2Concentration
        self.lightIntensity = lightIntensity
    }
    
    func passiveCharts(index: Int) -> PassiveChartData? {
        if stride(from: 0, to: latest.count, by: 1).contains(index) == false {
            return nil
        }
        
        var datas: [MeasurementData]
        let type = latest[index].itemType
        switch type {
        case .airTemperature:   datas = airTemperature
        case .airHumidity:      datas = airHumidity
        case .soilTemperature:  datas = soilTemperature
        case .soilHumidity:     datas = soilHumidity
        case .co2Concentration: datas = co2Concentration
        case .lightIntensity:   datas = lightIntensity
        default:                datas = []
        }
        
        if datas.isEmpty {
            return nil
        }
        
        var columns = [LineColumn]()
        for i in 0..<datas.count {
            if i == 0 || i == datas.count - 1 {
                columns.append(LineColumn(value: CGFloat(datas[i].value), prompt: datas[i].updateDate))
            } else {
                columns.append(LineColumn(value: CGFloat(datas[i].value), prompt: ""))
            }
        }
        
        return PassiveChartData(columns: columns, mtype: type)
    }
    
    func passiveCharts() -> [PassiveChartData] {
        var res = [PassiveChartData]()
        
        var config = PassiveChartData.Config()
        config.isArea = false
        
        var columns = airTemperature.map { LineColumn(value: CGFloat($0.value), prompt: "") }
        res.append(PassiveChartData(columns: columns, config: config, mtype: .airTemperature))
        
        columns = airHumidity.map { LineColumn(value: CGFloat($0.value), prompt: "") }
        res.append(PassiveChartData(columns: columns, config: config, mtype: .airHumidity))
        
        columns = soilTemperature.map { LineColumn(value: CGFloat($0.value), prompt: "") }
        res.append(PassiveChartData(columns: columns, config: config, mtype: .soilTemperature))
        
        columns = soilHumidity.map { LineColumn(value: CGFloat($0.value), prompt: "") }
        res.append(PassiveChartData(columns: columns, config: config, mtype: .soilHumidity))
        
        columns = co2Concentration.map { LineColumn(value: CGFloat($0.value / 10.0), prompt: "") }
        res.append(PassiveChartData(columns: columns, config: config, mtype: .co2Concentration))
        
        columns = lightIntensity.map { LineColumn(value: CGFloat($0.value / 10.0), prompt: "") }
        res.append(PassiveChartData(columns: columns, config: config, mtype: .lightIntensity))
        
        return res
    }
}
