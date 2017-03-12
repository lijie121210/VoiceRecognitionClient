//
//  DataCurveCell.swift
//  VGClient
//
//  Created by jie on 2017/3/11.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

class DataCurveCell: UICollectionViewCell {
    
    /// 项目名称
    @IBOutlet weak var titleLabel: UILabel!
    
    /// 单位
    @IBOutlet weak var unitLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    /// 绘图背景；用于清除或添加代表数据曲线的子视图
    @IBOutlet weak var canvasView: LineChart!
    
    @IBOutlet weak var popLabel: UILabel!
}
