//
//  MasterViewController.swift
//  VGClient
//
//  Created by jie on 2017/2/20.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit


/// Add MasterViewController as parent
/// self.parent is the containing view controller, and will be set a value after didMove(_:) method called.
extension RecordListViewController {
    var masterParent: MasterViewController? {
        return parent as? MasterViewController
    }
}


extension DashboardViewController {
    var masterParent: MasterViewController? {
        return parent as? MasterViewController
    }
}


/// Controller
///
class MasterViewController: UIViewController {
    
    @IBOutlet weak var dashboardContainer: UIView!
    
    @IBOutlet weak var dashboardTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var listeningButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var monitoringInfoLabel: UILabel!
    
    @IBOutlet weak var monitoringInfoCollectionView: UICollectionView!
    
    @IBOutlet weak var dataCurveLabel: UILabel!
    
    @IBOutlet weak var dataCurveCollectionView: UICollectionView!
    
    @IBOutlet weak var accessoryViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var accessoryLabel: UILabel!
    
    @IBOutlet weak var accessoryEditButton: UIButton!
    
    @IBOutlet weak var accessoryAddButton: UIButton!
    
    @IBOutlet weak var accessoryCollectionView: UICollectionView!
    
    @IBAction func didTapAccessoryEditButton(_ sender: Any) {
        
    }
    
    @IBAction func didTapAccessoryAddButton(_ sender: Any) {
    }
    
    
    /// It needs to be responsible for the full operation of the data, including access, playing and sending
    fileprivate var dataSource: AudioDataSource = AudioDataSource()
    
    fileprivate var audioOperator: AudioOperator!
    
    fileprivate var clientSocket: AudioClient = AudioClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// setup original layout
        resetLayout()
        
        /// setup background image base on user settting
        updateViewFromSettings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /// permission
        requestPermission()
        
        
        if AudioOperator.canRecord {
            showDashboard()
        }
        
        /// get existed local data
        
        fetchData()
        
        /// start networking connection
        
        clientSocket.connect()
        
        
        /// 去掉注释可以使得设备的集合视图完全显示，而不会滚动。
        /// accessoryViewHeightConstraint.constant = accessoryCollectionView.contentSize.height + 100.0
        /// scrollView.layoutIfNeeded()
    
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func requestPermission() {
        AudioOperator.requestAudioSessionAuthorization { permission in
            
            guard permission else {
                return
            }
            
            DispatchQueue.main.async(execute: self.showDashboard)
            
            guard #available(iOS 10.0, *) else {
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                AudioOperator.requestSpeechAuthorization(completion: { (_) in })
            })
        }
    }
    
    func fetchData() {
        
        let loadData = { (result: [AudioData]) in
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                
                self.recordList?.reloadDataSource(data: result)
                
            })
        }
        
        dataSource.loadLocalData(completion: loadData)
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
    
    fileprivate var dashboard: DashboardViewController? {
        
        return childViewControllers.filter { $0 is DashboardViewController }.first as? DashboardViewController
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
        
        showDashboardFully()
        
        recordDidStart()
        
        return true
    }
    
    func attemptToCancelRecording() {
        
        showDashboard()
        
        /// trigger no delegate and block
        audioOperator.cancelRecord()
        
        self.recordDidEnd()
    }
    
    func attemptToStopRecording() {
        
        showDashboard()
        
        /// The next operation should handle in completion handler.
        audioOperator.stopRecording()
    }
    
    /// this method will try to send current data of data source.
    func attemptToSendRecord() {
        
        showDashboard()
        
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
            
            self.dashboard?.update(consoleTimeLabel: time)
            
        }, completionHandler: { (_, _, data) in
            
            self.recordDidEnd()
            
            guard let data = data else { return }
            
            self.startRecognition(data: data)
            
        }, failureHandler: { (_, error) in
            
            self.showDashboard()
            
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



/// Adjustment of layouts
extension MasterViewController {
    
    struct Constants {
        
        static let show_dashboard: CGFloat = 120
        static let show_dashboard_fully: CGFloat = 280
        static let hide_dashboard_fully: CGFloat = 0
    }
    
    fileprivate func resetLayout() {
        
        dashboardTopConstraint.constant = Constants.hide_dashboard_fully

        view.layoutIfNeeded()
    }
    
    fileprivate func showDashboard() {
        
        UIView.animate(withDuration: 0.25) {
            self.dashboardTopConstraint.constant = Constants.show_dashboard
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func showDashboardFully() {
        
        UIView.animate(withDuration: 0.25) {
            self.dashboardTopConstraint.constant = Constants.show_dashboard_fully
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func hideDashboardFully() {
        
        UIView.animate(withDuration: 0.25) {
            self.dashboardTopConstraint.constant = Constants.hide_dashboard_fully
            self.view.layoutIfNeeded()
        }
    }
}











///



extension MasterViewController: UICollectionViewDelegate {
    
    
}


extension MasterViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if collectionView == self.accessoryCollectionView {
            return 2
        }
        
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.accessoryCollectionView {
            
            return ((DataManager.default.fake_data[2] as! [Any])[section] as! [AccessoryData]).count
        }
        
        if collectionView == self.monitoringInfoCollectionView {
            
            return (DataManager.default.fake_data[0] as! [MeasurementData]).count
        
        }
        
        if collectionView == self.dataCurveCollectionView {
            
            return (DataManager.default.fake_data[1] as! [MeasurementCurveData]).count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == monitoringInfoCollectionView {
            
            /// monitoring information collection view
            
            let data = (DataManager.default.fake_data[0] as! [MeasurementData])[indexPath.item]
            
            let micell = collectionView.dequeueReusableCell(withReuseIdentifier: "MInfoCell", for: indexPath) as! MInfoCell
            
            micell.imageView.image = data.itemImage
            
            micell.titleLabel.text = data.itemType.textDescription
            
            micell.timeLabel.text = data.updateDate
            
            micell.valueLabel.text = String(data.value)
            
            micell.unitLabel.text = data.itemUnit.rawValue
            
            return micell
        } else if collectionView == dataCurveCollectionView {
            
            /// data curve collection view
            
            let data = (DataManager.default.fake_data[1] as! [MeasurementCurveData])[indexPath.item]
            
            let dccell = collectionView.dequeueReusableCell(withReuseIdentifier: "DataCurveCell", for: indexPath) as! DataCurveCell
            
            dccell.titleLabel.text = data.title
            dccell.dateLabel.text = data.duration
            dccell.unitLabel.text = "单位: " + data.type.unit.rawValue
            
//            dccell.canvasView.subviews.forEach { $0.removeFromSuperview() }
            
            dccell.canvasView.clearAll()
            
//            let frame = CGRect(x: 0, y: 0, width: dccell.canvasView.frame.width, height: dccell.canvasView.frame.height)
//            let chart = LineChart(frame: frame)
            
            dccell.canvasView.animation.enabled = data.config.isAnimatable
            dccell.canvasView.area = data.config.isArea
            dccell.canvasView.x.labels.visible = data.config.isLabelsVisible
            dccell.canvasView.y.labels.visible = data.config.isLabelsVisible
            dccell.canvasView.x.grid.count = data.config.gridCount
            dccell.canvasView.y.grid.count = data.config.gridCount
            
            let color = dccell.canvasView.colors[randomNumber(from: 0, to: dccell.canvasView.colors.count)]
            dccell.canvasView.colors = [color]
            
            dccell.canvasView.x.labels.values = data.xlabels
            dccell.canvasView.addLine(data.datas)
            
//            dccell.canvasView.addSubview(chart)
            
            return dccell
            
        } else if indexPath.section == 0 {
            
            let data = ((DataManager.default.fake_data[2] as! [Any])[0] as! [AccessoryData])[indexPath.item]
            
            let accell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultiActionCell", for: indexPath) as! MultiActionCell
            
            accell.titlelLabel.text = data.name
            
            accell.imageView.image = data.image
            
            accell.delegate = self
            
            return accell
            
        } else {
            
            let data = ((DataManager.default.fake_data[2] as! [Any])[1] as! [AccessoryData])[indexPath.item]
            
            let accell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleActionCell", for: indexPath) as! SingleActionCell
            
            accell.titleLabel.text = data.name
            
            accell.infoLabel.text = data.state.textDescription
            
            accell.imageView.image = data.image
            
            return accell
        }
        
    }
    
}


extension MasterViewController: MultiActionCellDelegate {
    
    func cell(_ cell: MultiActionCell, isTapped action: AccessoryAction) {
        
        print(self, #function)
    }

    
    
}





