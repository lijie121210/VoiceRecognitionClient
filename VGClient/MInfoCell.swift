//
//  MInfoCell.swift
//  VGClient
//
//  Created by jie on 2017/3/10.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

class MInfoCell: UICollectionViewCell {
    
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
}



class DataCurveCell: UICollectionViewCell {
    
    /// 项目名称
    @IBOutlet weak var titleLabel: UILabel!
    
    /// 单位
    @IBOutlet weak var unitLabel: UILabel!
}


class SingleActionCell: UICollectionViewCell {
    
    
}

class MultiActionCell: UICollectionViewCell {
    
    
    
}
