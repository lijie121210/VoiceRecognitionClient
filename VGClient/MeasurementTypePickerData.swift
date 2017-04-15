//
//  MeasurementTypePickerData.swift
//  VGClient
//
//  Created by viwii on 2017/4/5.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation

/// 监测数据类型选择器的标题数据；
///
struct MeasurementTypePickerData {
    
    private var data: [String]
    
    var count: Int {
        return data.count
    }
    
    var isEmpty: Bool {
        return data.isEmpty
    }
    
    subscript(index: Int) -> String {
        return data[index]
    }
    
    init() {
        data = [String]()
        
        stride(from: 0, through: 5, by: 1).forEach {
            if let t = MeasurementType(rawValue: $0) {
                data.append(t.textDescription)
            }
        }
    }
}
