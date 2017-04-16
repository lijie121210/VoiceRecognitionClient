//
//  MasterViewController.swift
//  VGClient
//
//  Created by viwii on 2017/4/16.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit
import PulsingHalo

/// Main controller
///
class MasterViewController: UIViewController {
    
    // MARK - Outlet
    
    /// 背景图片
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    /// 设置按钮
    @IBOutlet weak var userButtonContainer: RectCornerView!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var analysisButton: UIButton!
    
    /// 表示正在聆听的按钮
    @IBOutlet weak var listeningButton: PulsingHaloButton!
    
    /// 主滚动视图
    @IBOutlet weak var scrollView: UIScrollView!
    
    /// 监测数据显示
    @IBOutlet weak var monitoringInfoLabel: UILabel!
    
    @IBOutlet weak var monitoringInfoCollectionView: UICollectionView!
    
    /// 绘图显示
    @IBOutlet weak var dataCurveLabel: UILabel!
    
    @IBOutlet weak var dataCurveCollectionView: UICollectionView!
    
    /// 附件操作与显示
    
    @IBOutlet weak var view3: UIView!
    
    @IBOutlet weak var accessoryViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var accessoryLabel: UILabel!
    
    @IBOutlet weak var accessoryEditButton: UIButton!
    
    @IBOutlet weak var accessoryAddButton: UIButton!
    
    @IBOutlet weak var accessoryCollectionView: UICollectionView!
}
