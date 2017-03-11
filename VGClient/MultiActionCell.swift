//
//  MultiActionCell.swift
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
    
    @IBOutlet weak var infoLabel: UILabel!
    
}


/// cell包含三个按钮，collectionview可以注册为代理以接受点击事件
/// 考虑到内存管理，使用代理还是比较安全的；

enum MultiAction: Int {
    case open, close, stop
}

protocol MultiActionCellDelegate: class {
    
    func cell(_ cell: MultiActionCell, isTapped action: MultiAction)
}

class MultiActionCell: UICollectionViewCell {
    
    @IBOutlet weak var container: RectCornerView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titlelLabel: UILabel!
    
    @IBOutlet weak var actionStack: UIStackView!
    
    @IBOutlet weak var openButton: UIButton!
    
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var closeButton: UIButton!
    
    weak var delegate: MultiActionCellDelegate?
    
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
