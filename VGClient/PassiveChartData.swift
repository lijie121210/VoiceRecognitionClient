//
//  PassiveChartData.swift
//  VGClient
//
//  Created by viwii on 2017/4/15.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

/// `Type` define
/// 用于描述随着数据类型的改变，而绘制新的类型的最近变化曲线, 的数据类型.
///
struct PassiveChartData {
    
    /// 图表的默认配置
    struct Config {
        var isAnimatable: Bool = true
        var isArea: Bool = true
        
        var isXLabelsVisible: Bool = true
        var isYLabelsVisible: Bool = true
        
        var xGridCount: CGFloat = 5
        var yGridCount: CGFloat = 5
        
        var xAxisInset: CGFloat = 30
        var yAxisInset: CGFloat = 30
        
        var colors: [UIColor] = UIColor.Flat.colors
    }
    
    var columns: [LineColumn]
    
    var config: Config
    
    var mtype: MeasurementType
    
    init(columns: [LineColumn], config: Config = Config(), mtype: MeasurementType) {
        self.columns = columns
        self.config = config
        self.mtype = mtype
    }
}
