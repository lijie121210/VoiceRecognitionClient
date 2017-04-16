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
    
    init(itemType: MeasurementType, value: Double, updateDate: String) {
        self.itemType = itemType
        self.value = value
        self.updateDate = updateDate
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







