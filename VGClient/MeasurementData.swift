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
public struct MeasurementData {
    
    let itemType: MeasurementType
    
    var itemUnit: MeasurementUnit { return itemType.unit }
    
    var itemImage: UIImage? { return UIImage(named: itemType.icon) }

    let value: Double
    
    let updateDate: String
    
    var range: Range<Double>?
    
    init(itemType: MeasurementType, value: Double, updateDate: String, range: Range<Double>? = nil) {
        self.itemType = itemType
        self.value = value
        self.updateDate = updateDate
        self.range = range
    }
}

