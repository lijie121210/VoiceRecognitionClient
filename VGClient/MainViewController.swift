//
//  MainViewController.swift
//  VGClient
//
//  Created by viwii on 2017/4/14.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    // MARK - Outlet
    
    /// 背景图片
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    /// 表示正在聆听的按钮
    @IBOutlet weak var listeningButton: PulsingHaloButton!
    
    /// 主滚动视图
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var measurementContainer: UIView!
    
    /// 切换大棚按钮
    @IBOutlet weak var housesContainer: RectCornerView!
    
    @IBOutlet weak var housesButton: UIButton!
    
    /// 设置按钮
    @IBOutlet weak var settingContainer: RectCornerView!
    
    @IBOutlet weak var settingButton: UIButton!
    
    /// 监测数据显示
    @IBOutlet weak var measurementInfoLabel: UILabel!
    
    @IBOutlet weak var measurementCollectionView: UICollectionView!
    
    @IBOutlet weak var curveContainer: UIView!
    
    /// 绘图显示
    @IBOutlet weak var curveInfoLabel: UILabel!
    
    @IBOutlet weak var analysisContainer: RectCornerView!
    
    @IBOutlet weak var analysisButton: UIButton!
    
    @IBOutlet weak var chartContainer: RectCornerView!
    
    @IBOutlet weak var chartTitleLabel: UILabel!
    
    @IBOutlet weak var chartPromptLabel: UILabel!
    
    @IBOutlet weak var lineChart: LineChartView!
    
    
    /// 附件操作与显示
    @IBOutlet weak var accessoryContainer: UIView!
    
    @IBOutlet weak var accessoryLabel: UILabel!
    
    @IBOutlet weak var accessoryEditContainer: RectCornerView!

    @IBOutlet weak var accessoryEditButton: UIButton!
    
    @IBOutlet weak var accessoryAddContainer: RectCornerView!
    
    @IBOutlet weak var accessoryAddButton: UIButton!
    
    @IBOutlet weak var accessoryCollectionView: UICollectionView!
    
    
    // MARK - Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// `Note`: 一定要在layout之前设置代理.
        ///
        /// 用于计算每个cell的高度.
        if let layout = accessoryCollectionView.collectionViewLayout as? AlternateLayout {
            layout.delegate = self
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}


extension MainViewController: AlternateLayoutDelegate {
    
    /// 附件视图的布局
    /// 计算每一个cell的高度，这里只用类型区分
    func collectionView(_ collectionView: UICollectionView, heightForItem atIndexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        
        guard let accdatas = DataManager.default.fake_data[2] as? [AccessoryData] else {
            return 0
        }
        
        return accdatas[atIndexPath.item].type.isSingleActionTypes ? 130 : 170
    }
}

/* 该界面可能更改设置，于是实现设置更改的代理人，可以接受在该页面更改设置时的通知.
 * 如果想得到在任何界面设置修改的通知，需要在通知中心注册
 */
extension MainViewController: SettingViewControllerDelegate {
    
    func setting(controller: SettingViewController, didChangeValueOf keyPath: AudioDefaultValue.KeyPath, to newValue: Any) {
        
        guard keyPath == .isHiddenBackgroundImage, let isHidden = newValue as? Bool else {
            return
        }
        
        updateViewFromSettings(isHidden: isHidden)
    }
    
    func updateViewFromSettings(isHidden: Bool = AudioDefaultValue.isHiddenBackgroundImage) {
        
        backgroundImageView.isHidden = isHidden
        
    }
}
