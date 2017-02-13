//
//  ViewController.swift
//  VGClient
//
//  Created by jie on 2017/2/11.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit






enum RecordState: Int, Equatable {
    case idle
    case recording
    case playing
    case holding
    case glancing
}

enum PromptText {
    
    enum PlayButtonTitle: String {
        case play = "播放"
        case stop = "停止"
    }
    
    enum StateLabelTitle: String {
        case cancel = "取消录制"
        case recording = "正在录制"
        case finish = "录制完成"
        case playing = "正在播放"
        case recordfail = "录制失败"
        case playfail = "播放失败"
    }
}



class MainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var actionsContainerView: RectCornerView!
    @IBOutlet weak var actionsContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var actionsBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var actionsSepatatorView: RectCornerView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var sendButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var recordPromptContainerView: RectCornerView!
    
    @IBOutlet weak var stateLabel: UILabel!
    
    @IBOutlet weak var timeIntervalLabel: UILabel!
    
    var recordState: RecordState = .idle
    
    var recorder: AudioRecorder!
    var player: AudioPlayer!
    
    var dataManager: AudioDataManager = AudioDataManager()
    
    var recordingTimeInterval: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// setup views
        setupPlayButton()
        
        shrinkActionsConstainer()
        
        /// setup data
        
        recorder = AudioRecorder(delegate: self)
        
        player = AudioPlayer.sharedPlayer
        
        dataManager.loadLocalData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: <#T##() -> Void#>)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    /// Views
    
    /// Set up play button.
    func setupPlayButton() {
        
        playButton.backgroundColor = UIColor.white
        playButton.layer.cornerRadius = 15.0
        playButton.layer.shadowColor = UIColor.lightGray.cgColor
        playButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        playButton.layer.shadowRadius = 10.0
        playButton.layer.shadowOpacity = 0.3
    }
    
    /// Set send button hidden and only show record button on the screen.
    func shrinkActionsConstainer() {
        
        tableView.isUserInteractionEnabled = true
        
        recordButton.setTitle("开始", for: .normal)
        
        UIView.animate(withDuration: 0.2) { 
            self.actionsSepatatorView.alpha = 0.0
            self.sendButtonWidthConstraint.constant = 0.0
            self.actionsContainerWidthConstraint.constant = 60.0
            self.actionsBottomConstraint.constant = 8.0
            
            self.actionsContainerView.layoutIfNeeded()
            self.actionsContainerView.setCornerRadius(radius: 30.0)
        }
    }
    
    /// Show record button on left and send button on right
    func expandActionsConstainer() {
        
        tableView.isUserInteractionEnabled = false

        recordButton.setTitle("取消", for: .normal)
        
        UIView.animate(withDuration: 0.2) {
            self.actionsSepatatorView.alpha = 1.0
            self.sendButtonWidthConstraint.constant = 60.0
            self.actionsContainerWidthConstraint.constant = 120.0
            self.actionsBottomConstraint.constant = 188.0
            
            self.actionsContainerView.layoutIfNeeded()
            self.actionsContainerView.setCornerRadius(radius: 15.0)
        }
    }
    
    /// Update text of recording time interval label with timeInterval
    func updateRecordingTimeIntervalLable(timeInterval: TimeInterval) {
        
        if recordingTimeInterval == Int(timeInterval) {
            return
        }
        
        let work = DispatchWorkItem {
            self.recordingTimeInterval = Int(timeInterval)
            self.timeIntervalLabel.text = timeInterval.dateDescription()
        }
        
        DispatchQueue.main.async(execute: work)
    }
    
    
    func updateRecordingStateLabel(text: PromptText.StateLabelTitle) {
        
        stateLabel.text = text.rawValue
    }
    
    func updatePlayButton(title: PromptText.PlayButtonTitle) {
        
        playButton.setTitle(title.rawValue, for: .normal)
    }
    
    func glance(data: AudioData) {
        
        recordState = .glancing
        
        expandActionsConstainer()
        
        dataManager.currentData = data
        
        updatePlayButton(title: .play)
        updateRecordingStateLabel(text: .finish)
        updateRecordingTimeIntervalLable(timeInterval: data.duration)
    }
    
    
    func successedARecording(result: (String, Date, TimeInterval)) {
        
        let originCount = dataManager.datas.count
        
        dataManager.append(newData: result)
        
        let count = dataManager.datas.count
        
        let dx = count - originCount
        
        var indexs = [IndexPath]()
        for i in 0..<dx {
            indexs.append( IndexPath(row: originCount + i, section: 0) )
        }
        
        tableView.insertRows(at: indexs, with: .automatic)
    }
    
    func failedARecording() {
        
        dataManager.updateCurrentData(newData: nil)
        
        updateRecordingStateLabel(text: .recordfail)
        updatePlayButton(title: .play)
        updateRecordingTimeIntervalLable(timeInterval: 0)
        
        playButton.isEnabled = false
        sendButton.isEnabled = false
    }
    
    func cancelledARecording() {
        
        recordState = .idle
        
        shrinkActionsConstainer()
    }
    
    func sendARecording(data: AudioData) {
        
        dataManager.upload(data: data)
    }
    
    func startARecording() {
        
        let name = "\(Date.currentName).wav"
        let localURL = AudioDataManager.dataURL(with: name)
        
        recorder.startRecording(filename: name, storageURL: localURL)
    }
    
    func play(record: AudioData, completion: ( (AudioPlayer, Bool) -> () )? = nil) {
        
        player.startPlaying(url: record.localURL, completion: completion)
    }
    
    
    /// Record button
    
    
    /* User can tap record button at any state.
     When recordState is .idle, begin a recording, otherwise, cancel that operation
     */
    @IBAction func didTapRecordButton(_ sender: UIButton) {
        
        let resetToIdle = {
            self.recordState = .idle
            
            /// hide recording prompt view.
            self.shrinkActionsConstainer()
            
            self.updateRecordingStateLabel(text: .cancel)
        }
        let setRecord = {
            self.recordState = .recording
            
            /// show up recording prompt view.
            self.expandActionsConstainer()
            
            self.updateRecordingStateLabel(text: .recording)
        }
        
        playButton.isEnabled = true
        sendButton.isEnabled = true
        
        updatePlayButton(title: .stop)
        updateRecordingTimeIntervalLable(timeInterval: 0)
        
        switch recordState {
        case .idle:
            setRecord()
            /// reset data
            dataManager.currentData = nil
            /// start a recording
            DispatchQueue.main.async(execute: startARecording)

        case .recording:
            
            recorder.cancelRecording()
            resetToIdle()
        case .holding:
            
            resetToIdle()
        case .playing:
            
            player.stopPlaying()
            resetToIdle()
        case .glancing:
            
            resetToIdle()
        }
        
    }
    
    
    @IBAction func didTapPlayButton(_ sender: UIButton) {
        
        let recordWork = DispatchWorkItem {
            self.recorder.stopRecording()
        }
        
        switch recordState {
        case .recording:
            /// change to glancing
            recordState = .holding
            
            /// stop recording
            DispatchQueue.main.async(execute: recordWork)
            
            updateRecordingStateLabel(text: .finish)

            updatePlayButton(title: .play)
        case .holding, .glancing:
            
            if let data = dataManager.currentData {
                /// change to playing
                recordState = .playing

                updateRecordingStateLabel(text: .playing)
    
                /// change playing to stopping state
                updatePlayButton(title: .stop)
                
                /// start playing a record
                
                play(record: data, completion: { (p, f) in
                    self.recordState = .holding
                    
                    self.updateRecordingStateLabel(text: f ? .finish : .playfail)
                    
                    self.updatePlayButton(title: .play)
                })
            }
        case .playing:
            
            recordState = .holding
            
            player.stopPlaying()

            updateRecordingStateLabel(text: .finish)

            updatePlayButton(title: .play)
        default:
            break
        }
    }
    
    @IBAction func didTapSendButton(_ sender: UIButton) {
        
        switch recordState {
        case .recording:
            DispatchQueue.main.async { self.recorder.stopRecording() }
        case .playing:
            player.stopPlaying()
        default:
            break
        }
        
        shrinkActionsConstainer()
        updateRecordingStateLabel(text: .finish)
        updatePlayButton(title: .play)
        
        /// change to idle
        recordState = .idle
        
        /// Make sure there is a data
        guard let data = dataManager.currentData else {
            return
        }
        
        /// send data
        sendARecording(data: data)
    }
    
}



extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    /// Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        glance(data: dataManager.datas[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            if dataManager.remove(at: indexPath.row) {
                
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        default:
            break
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let data = dataManager.datas[indexPath.row]
        
        cell.textLabel?.text = data.recordDate.description
        
        cell.detailTextLabel?.text = data.duration.dateDescription()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let button = UIButton(frame: CGRect(x: 0, y: 0, width: tableView.bounds.height, height: 60))
        button.setTitle("  已录制", for: .normal)
        button.setTitleColor( .darkGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 26)
        button.contentHorizontalAlignment = .left
        button.backgroundColor = UIColor(white: 1, alpha: 0.6)
        return button
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
}


extension MainViewController: AudioRecorderDelegate {
    internal func audioRecorder(_ recorder: AudioRecorder, isFinished result: (String, Date, TimeInterval)?) {
        if let r = result {
            
            successedARecording(result: r)
        } else {
            
            failedARecording()
        }
    }

    internal func audioRecorder(_ recorder: AudioRecorder, isCancelled reason: String) {
        print("audioRecorder: isCancelled")
        
        failedARecording()
    }

    /// Calls are very frequent
    internal func audioRecorder(_ recorder: AudioRecorder, timeDuration currentTime: TimeInterval) {
        
        updateRecordingTimeIntervalLable(timeInterval: currentTime)
    }
    
    /// Calls are very frequent
    internal func audioRecorder(_ recorder: AudioRecorder, averagePower power: Float) {
        
    }
}








