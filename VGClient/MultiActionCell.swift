//
//  MultiActionCell.swift
//  VGClient
//
//  Created by jie on 2017/3/11.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit



/// cell包含三个按钮，collectionview可以注册为代理以接受点击事件
/// 考虑到内存管理，使用代理还是比较安全的；

protocol MultiActionCellDelegate: class {
    
    func cell(_ cell: MultiActionCell, isTapped action: AccessoryAction)
}

class MultiActionCell: UICollectionViewCell {
    
    @IBOutlet weak var container: RectCornerView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titlelLabel: UILabel!
    
    /// 动作按钮安放在一个水平stack中
    
    @IBOutlet weak var actionStack: UIStackView!
    
    /// 三个动作按钮
    
    @IBOutlet weak var openButton: UIButton!
    
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var closeButton: UIButton!
    
    /// collectionview可以注册为代理以接受点击事件
    
    weak var delegate: MultiActionCellDelegate?
    
    /// 三个动作按钮的点击事件
    
    @IBAction func didTapOpenButton(_ sender: Any) {
        
        delegate?.cell(self, isTapped: .open)
    }
    
    @IBAction func didTapCloseButton(_ sender: Any) {
        
        delegate?.cell(self, isTapped: .close)
    }
    
    @IBAction func didTapStopButton(_ sender: Any) {
        
        delegate?.cell(self, isTapped: .stop)
    }
}
