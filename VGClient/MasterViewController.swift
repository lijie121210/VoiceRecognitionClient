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

    /// It needs to be responsible for the full operation of the data, including access, playing and sending
    fileprivate var dataSource: AudioDataSource = AudioDataSource()
    
    fileprivate var audioOperator: AudioOperator!
    
    fileprivate var clientSocket: AudioClient = AudioClient()
    
    
    // MARK - View Controller

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 一定要在layout之前设置代理；坑！
        ///
        /// 用于计算每个cell的高度.
        if let layout = accessoryCollectionView.collectionViewLayout as? AlternateLayout {
            layout.delegate = self
        }
        
        /// setup background image base on user settting
        updateViewFromSettings()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if PermissionDefaultValue.isRequestedPermission {
            scrollView.alpha = 1.0
        } else {
            scrollView.alpha = 0.0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if PermissionDefaultValue.isRequestedPermission {
            
            
            /// get existed local data
//            fetchData()
            
            /// start networking connection
//            clientSocket.connect()
            
            /// 去掉注释可以使得设备的集合视图完全显示，而不会滚动。
            expandScrollViewHeight()
            
        } else {
            
            /// 显示申请授权的页面
            requestPermission()
        }
        
        
        /// 接受开始录音的通知
        NotificationCenter.default.addObserver(self, selector: #selector(recordDidBegin), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        /// 移除接受通知
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let des = segue.destination as? AccessoryViewController else {
            return
        }
        
        des.delegate = self
        
        guard
            let id = segue.identifier, id == "\(AccessoryViewController.self)",
            let sender = sender as? [String:Any],
            let editing = sender["editing"] as? Bool, editing == true else {
                
                return
        }
        
        des.currentIndexPath = sender["indexPath"] as? IndexPath
        
        des.currentAccessory = sender["data"] as? AccessoryData
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    func requestPermission() {
        
        guard let authority = UIStoryboard(name: "Authority", bundle: nil).instantiateInitialViewController() else {
            return
        }
        
        show(authority, sender: nil)
    }
    
    func fetchData() {
        
        let loadData = { (result: [AudioData]) in
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                
                self.recordList?.reloadDataSource(data: result)
                
            })
        }
        
        dataSource.loadLocalData(completion: loadData)
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


/// Communication with Recordlist
extension MasterViewController {

    func deletingItem(at index: IndexPath, with data: AudioData, completion: @escaping (Bool) -> ()) {
        
        dataSource.remove(at: index.item) { finish in
            DispatchQueue.main.async {
                completion(finish)
            }
        }
    }
    
    func playItem(at index: IndexPath, with data: AudioData) -> Bool {
        
        if !AudioOperator.canRecord {
            return false
        }
        setupAudioOperatorAsPlayer()
        
        let start = audioOperator.startPlaying(url: data.localURL)
        
        if !start {
            return false
        }
        
        return true
    }
    
    func stopPlayItem(at index: IndexPath, with data: AudioData) {
        
        audioOperator.stopPlaying()
    }
    
    func sendItem(at index: IndexPath, with data: AudioData) {
        
        guard let data = data.data else {
            return
        }
        
        send(data: data)
    }
    
    func send(data: Data) {
        
        
    }
}


/// Communication with Dashboard
extension MasterViewController {
    
    func shouldStartRecording() -> Bool {
        
        if !AudioOperator.canRecord {
            return false
        }
        
        if let audioOperator = audioOperator, audioOperator.isPlaying {
            recordList?.playDidComplete()
        }
        
        setupAudioOperatorAsRecorder()
        
        let name = "\(Date.currentName).wav"
        
        let localURL = FileManager.dataURL(with: name)
        
        let start = audioOperator.startRecording(filename: name, storageURL: localURL)
        
        if !start {
            return false
        }
        
        recordDidStart()
        
        return true
    }
    
    func attemptToCancelRecording() {
        
        /// trigger no delegate and block
        audioOperator.cancelRecord()
        
        self.recordDidEnd()
    }
    
    func attemptToStopRecording() {
        
        /// The next operation should handle in completion handler.
        audioOperator.stopRecording()
    }
    
    /// this method will try to send current data of data source.
    func attemptToSendRecord() {
        
        if audioOperator.isRecording {
            
            audioOperator.stopRecording()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            guard let data = self.dataSource.currentData?.data else {
                print(self, #function, "No data found")
                return
            }
            
            self.send(data: data)
        }
    }
    
}




/// Handle record callback
extension MasterViewController {
    
    /// convenience methods
    
    func setupAudioOperatorAsRecorder() {
        
        if let audioOperator = audioOperator {
            audioOperator.releaseResource()
            self.audioOperator = nil
        }
        
        audioOperator = AudioOperator(averagePowerReport: { (_, power) in
            
        }, timeIntervalReport: { (_, time) in
            
            //
            
        }, completionHandler: { (_, _, data) in
            
            self.recordDidEnd()
            
            guard let data = data else { return }
            
            self.startRecognition(data: data)
            
        }, failureHandler: { (_, error) in
            
            //
            
            self.recordDidEnd()
            
            print(self, #function, error?.localizedDescription ?? "unknown record error")
        })
    }
    
    func recordDidStart() {
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            
            self.recordList?.isActionEnabled = false
        }
    }
    func recordDidEnd() {
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            
            self.recordList?.isActionEnabled = true
        }
    }
    
    
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
            AudioOperator.delete(recordedItem: data.localURL)
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


/// handle player
extension MasterViewController {
    
    func setupAudioOperatorAsPlayer() {
        
        if let audioOperator = audioOperator {
            audioOperator.releaseResource()
            self.audioOperator = nil
        }
        
        audioOperator = AudioOperator(averagePowerReport: { (_, power) in
            
        }, timeIntervalReport: { (_, time) in
            
            self.recordList?.update(playState: time)
            
        }, completionHandler: { (_, finish, _) in
            
            self.recordList?.playDidComplete()
            
        }, failureHandler: { (_, error) in
            
            self.recordList?.playDidComplete()
        })
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















