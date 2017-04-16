//
//  MasterViewController.swift
//  VGClient
//
//  Created by jie on 2017/2/20.
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
    
    
    // MARK - Properties

    /// It needs to be responsible for the full operation of the data, 
    /// including access, playing and sending
    fileprivate var dataSource: AudioDataSource = AudioDataSource()
    
    fileprivate var audioOperator: AudioOperator!
    
    fileprivate var clientSocket: AudioClient = AudioClient()
    
    
    // MARK - View Controller

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// `Note`: 一定要在layout之前设置代理.
        ///
        /// 用于计算每个cell的高度.
        if let layout = accessoryCollectionView.collectionViewLayout as? AlternateLayout {
            layout.delegate = self
        }
        
        /// setup background image base on user settting
        updateViewFromSettings()
        
    }
    
    /// 这些方法都可能调用多次
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkPermissionAppearing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkPermissionAppeared()
        
        /// 接受开始录音的通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(recordDidBegin),
                                               name: .UIApplicationWillEnterForeground,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        /// 移除接受通知
        NotificationCenter.default.removeObserver(self,
                                                  name: .UIApplicationWillEnterForeground,
                                                  object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        /// 准备 编辑／添加 设备
        if let des = segue.destination as? AccessoryViewController {
            /// 设置控制器代理
            des.delegate = self
            /// 添加
            guard
                let id = segue.identifier, id == "\(AccessoryViewController.self)",
                let sender = sender as? [String:Any],
                let editing = sender["editing"] as? Bool, editing == true else {
                    return
            }
            des.currentIndexPath = sender["indexPath"] as? IndexPath
            des.currentAccessory = sender["data"] as? AccessoryData
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    /// 开始录音时广播通知的回调函数
    /// 之所以使用通知是因为，一旦应用进入一次后台，再打开，波纹效果就不见了，只能每次都添加。
    @objc fileprivate func recordDidBegin() {
        listeningButton.pulsing()
    }
    
}


/// Adding convenience calculation attribute
///
/** There is no need to increase the reference to children controllers, check them at any time.
 s: the master view controller; c: a view controller of a container view which will be added to s.
 When the master loading container views from the storyboard, the order is :
 --> s.prepare(for:sender:)
 --> c.viewDidLoad()
 --> s.addChildViewController
 --> c.didMove(toParentViewController:)
 after the s loaded all it's children view controllers
 --> s.viewDidLoad
 --> s.viewWillAppear
 --> c.viewWillAppear
 --> s.viewDidAppear
 --> c.viewDidAppear
 */
extension MasterViewController {
    
    
    fileprivate var recordList: RecordListViewController? {
        
        return childViewControllers.filter { $0 is RecordListViewController }.first as? RecordListViewController
    }
    
    fileprivate var authority: AuthorityViewController? {
        
        return childViewControllers.filter { $0 is AuthorityViewController }.first as? AuthorityViewController
    }
}



/// Handle record callback
extension MasterViewController {
    
    
    /// 录制到数据之后，开始进行识别
    
    func recognizeWithHMM(data: AudioData, completion: @escaping (String?) -> ()) {

        /// check data
        guard let data = data.data else {
            return completion(nil)
        }
        
        /// check connection
        guard clientSocket.connect() else {
            return completion(nil)
        }
        
        /// write to socket
        clientSocket.write(data: data, type: .audio, recognition: completion)
    }

    func startRecognition(data: AudioData) {
        
        /// will mutate the translation property.
        var data = data

        /// loading indicatior
        let orbit = OrbitAlertController.show(with: "正在上传...", on: self)
        
        /// failed!
        let recognizeFailed = {
            
            DispatchQueue.main.async {
                orbit?.update(prompt: "未完成!")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    OrbitAlertController.dismiss()
                })
            }
            
            /// 清理数据
//            AudioOperator.delete(recordedItem: data.localURL)
        }
        
        /// successed!
        let recognizeSuccessed = { (text: String) in
            DispatchQueue.main.async {
                
                orbit?.update(prompt: "完成!")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    OrbitAlertController.dismiss()
                })
                
                data.translation = text

                self.dataSource.append(data: data)
                
                self.recordList?.insert(data: data)
            }
        }
        
        /// recognition result callback
        let handleResult = { (text: String?) in
           
            if let text = text {
                
                recognizeSuccessed(text)
            } else {
                
                recognizeFailed()
            }
        }
        
        switch AudioDefaultValue.speechRecognitionEngine {
            
        case .hmm:
            
            recognizeWithHMM(data: data, completion: handleResult)
            
        case .siri:
            
            if #available(iOS 10.0, *) {
                
                AudioOperator.recognize(speech: data.localURL, completion: handleResult)
            } else {
                
                recognizeWithHMM(data: data, completion: handleResult)
            }
        }
        
    }
    
    
}




/* 该界面可能更改设置，于是实现设置更改的代理人，可以接受在该页面更改设置时的通知.
 * 如果想得到在任何界面设置修改的通知，需要在通知中心注册
 */
extension MasterViewController: SettingViewControllerDelegate {
    
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















