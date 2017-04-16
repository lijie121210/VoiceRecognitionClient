//
//  MeasurementCCell.swift
//  VGClient
//
//  Created by viwii on 2017/4/14.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

class MeasurementCCell: UICollectionViewCell {

    /// 图片
    @IBOutlet weak var imageView: UIImageView!
    
    /// 项目名称
    @IBOutlet weak var titleLabel: UILabel!
    
    /// 测量时间
    @IBOutlet weak var timeLabel: UILabel!
    
    /// 测量值
    @IBOutlet weak var valueLabel: UILabel!
    
    /// 单位
    @IBOutlet weak var unitLabel: UILabel!
    
    /// 阈值标题
    @IBOutlet weak var thresholdLabel: UILabel!
    
    @IBOutlet weak var rangeView: ThresholdRangeView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        thresholdLabel.text = "阈值"
    }

}
