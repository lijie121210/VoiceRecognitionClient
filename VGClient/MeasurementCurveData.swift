//
//  MeasurementChartData.swift
//  VGClient
//
//  Created by jie on 2017/3/11.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit
import Foundation




/// 代表图上的一列，包括点的值，和x轴上的说明文字
struct LineColumn {
    
    let value: CGFloat
    
    let prompt: String
}

/// 图表的默认配置
struct LineConfig {
    
    var isAnimatable: Bool = true
    var isLabelsVisible: Bool = true
    var isArea: Bool = true
    var gridCount: CGFloat = 8
}

/// 测量数据绘制图表的数据结构
struct MeasurementCurveData {
    
    var type: MeasurementType
    
    var fromDate: String
    
    var toDate: String
    
    var columns: [LineColumn]
    
    var config: LineConfig = LineConfig()
    
    /// 点以及点的说明
    
    var xlabels: [String] {
        
        return columns.map { $0.prompt }
    }
    
    var datas: [CGFloat] {
        
        return columns.map { $0.value }
    }
    
    /// 图表的标题就是各个监测类型在一段时间段中的变化
    
    var duration: String {
        
        return fromDate + " —— " + toDate
    }
    
    var title: String {
        return type.textDescription + "数据变化曲线图"
    }
    
    init(type: MeasurementType, fromDate: String, toDate: String, columns: [LineColumn], config: LineConfig = LineConfig()) {
        self.type = type
        self.fromDate = fromDate
        self.toDate = toDate
        self.columns = columns
        self.config = config
    }
}





