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
extension AuthorityViewController {
    var masterParent: MasterViewController? {
        return parent as? MasterViewController
    }
}


/// Controller
///
class MasterViewController: UIViewController {
    
    @IBOutlet weak var recordListContainer: UIView!
    @IBOutlet weak var dashboardContainer: UIView!
    @IBOutlet weak var authorityContainer: UIView!
    
    @IBOutlet weak var dashboardTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var authorityTopConstraint: NSLayoutConstraint!
    
    /// Add a UISwipeGestureRecognizer
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var orbitContainerView: RectCornerView!
    @IBOutlet weak var orbitView: OrbitView!
    @IBOutlet weak var orbitTitleLabel: UILabel!
    
    
    /// It needs to be responsible for the full operation of the data, including access, playing and sending
    fileprivate var dataSource: AudioDataSource = AudioDataSource()
    
    fileprivate var audioOperator: AudioOperator!
    
    fileprivate var clientSocket: AudioClient = AudioClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// setup original layout
        resetLayout()
        
        updateViewFromSettings()
        
        orbitView.launchOrbit()
        
        hideLoadingIndicator()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /// permission
        
        AudioOperator.requestAudioSessionAuthorization { permission in
            
            print(self, #function, permission)
            
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
        
        if AudioOperator.canRecord {
            self.showDashboard()
        }
        
        /// get existed local data

        let loadData = { (result: [AudioData]) in
            DispatchQueue.main.async {
                self.recordList?.reloadDataSource(data: result)
            }
        }

        dataSource.loadLocalData(completion: loadData)
        
        /// start networking connection
        
        clientSocket.connect()

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func didTapSettingButton(_ sender: UIButton) {
        
        self.showAuthority()

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
        
        if !clientSocket.isConnected {
            clientSocket.connect()
        }
        clientSocket.write(data: data, type: .audio, progression: { (progress) in
            
            print(self, #function, progress)
        }) { (finish) in
            
            print(self, #function, finish)
        }
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



/// Communication with Authority
extension MasterViewController {
    
    func attemptToCancelSetting() {
        
        hideAuthority()
        
        updateViewFromSettings()
    }
    
    func updateViewFromSettings() {
        
        backgroundImageView.isHidden = AudioDefaultValue.default.isHiddenBackgroundImage
        
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            completion(nil)
        }
    }

    func startRecognition(data: AudioData) {
        
        var data = data

        /// 显示加载动画
        updateOrbit(title: .start)
        showLoadingIndicator()
        
        let recognizeFailed = {
            DispatchQueue.main.async {
                
                self.updateOrbit(title: .fail)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    self.hideLoadingIndicator()
                })
            }
            
            /// 清理数据
            AudioOperator.delete(recordedItem: data.localURL)
        }
        
        let recognizeSuccessed = { (text: String) in
            DispatchQueue.main.async {

                self.updateOrbit(title: .success)

                data.translation = text

                self.dataSource.append(data: data)
                
                self.recordList?.insert(data: data)
            }
        }
        
        let handleResult = { (text: String?) in
            
            guard let text = text else {
                recognizeFailed()
                return
            }
            recognizeSuccessed(text)
        }
        
        switch AudioDefaultValue.default.speechRecognitionEngine {
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



/// update title of loading label
extension MasterViewController {
    
    enum OrbitTitle: String {
        case start = "正在识别..."
        case fail = "识别失败..."
        case success = "识别成功..."
    }
    
    fileprivate func updateOrbit(title: OrbitTitle) {
        
        orbitTitleLabel.text = title.rawValue
    }
}


/// Adjustment of layouts
extension MasterViewController {
    
    struct Constants {
        
        static let show_dashboard: CGFloat = 120
        static let show_dashboard_fully: CGFloat = 280
        static let hide_dashboard_fully: CGFloat = 0
        
        static let show_authority: CGFloat = 0
        static var hide_authority: CGFloat {
            
            return UIScreen.main.bounds.height
        }
    }
    
    fileprivate func resetLayout() {
        
        dashboardTopConstraint.constant = Constants.hide_dashboard_fully
        authorityTopConstraint.constant = Constants.hide_authority
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
    
    fileprivate func showAuthority() {
        
        UIView.animate(withDuration: 0.25) {
            self.authorityTopConstraint.constant = Constants.show_authority
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func hideAuthority() {
        
        UIView.animate(withDuration: 0.25) {
            self.authorityTopConstraint.constant = Constants.hide_authority
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func showLoadingIndicator() {
        
        UIView.animate(withDuration: 0.25) { 
            self.orbitContainerView.isHidden = false
        }
    }
    
    fileprivate func hideLoadingIndicator() {
        
        UIView.animate(withDuration: 0.25) { 
            self.orbitContainerView.isHidden = true
        }
    }
}
