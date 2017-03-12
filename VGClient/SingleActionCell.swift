//
//  SingleActionCell.swift
//  VGClient
//
//  Created by jie on 2017/3/11.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

/// 这些设备都是打开，关闭，两个状态，所以直接点击cell操作；
class SingleActionCell: UICollectionViewCell {
    
    @IBOutlet weak var container: RectCornerView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    /// 状态信息
    
    @IBOutlet weak var infoLabel: UILabel!
    
}
