//
//  MonitorInfoData.swift
//  VGClient
//
//  Created by jie on 2017/3/11.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit


/// 监控信息数据结构
///
struct MeasurementData {
    
    let itemType: MeasurementType
    
    var itemUnit: MeasurementUnit { return itemType.unit }
    
    var itemImage: UIImage? { return UIImage(named: itemType.icon) }

    let value: Double
    
    let updateDate: String
    
    var threshold: MeasurementThreshold?
    
    init(itemType: MeasurementType, value: Double, updateDate: String, threshold: MeasurementThreshold? = nil) {
        self.itemType = itemType
        self.value = value
        self.updateDate = updateDate
        self.threshold = threshold
    }
    
    
}

extension MeasurementData {
    /// 从网络数据解析出数据的便利方法
    static func makeIntegratedMeasurements(from jsonData: Data) throws -> [MeasurementData] {
        let thejson = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        
        var res = [MeasurementData]()
        
        guard let json = thejson as? [String:Any] else { return res }
        
        for (key, value) in json {
            guard
                let type = MeasurementType(origin: key),
                let value = value as? [String:Any],
                let time = value["time"] as? String,
                let val = value["value"] as? Double else { continue }
            
            let data = MeasurementData(itemType: type, value: val, updateDate: time)
            
            res.append(data)
        }
        
        return res
    }
    
    static func makeMeasurements(from jsonData: Data) throws -> [MeasurementData] {
        let container = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        var res = [MeasurementData]()
        
        guard let jsonobj = container as? [String:Any] else { return res }
        
        for (key, value) in jsonobj {
            guard
                let type = MeasurementType(origin: key),
                let array = value as? [Any] else {
                    continue
            }
            array.forEach({ (item) in
                guard
                    let json = item as? [String:Any],
                    let time = json["time"] as? String,
                    let val = json["value"] as? Double else {
                        return
                }
                let data = MeasurementData(itemType: type, value: val, updateDate: time)
                
                res.append(data)
            })
        }
        return res
    }
}


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
            guard let type = MeasurementType(origin: key), let array = value as? [Any] else {
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





