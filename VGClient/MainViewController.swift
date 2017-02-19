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
    
    enum RecordButtonTitle: String {
        case begin = "开始"
        case cancel = "取消"
    }
    
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
        
        hideRecordPromptContainerView()
        
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
        
        AudioDataManager.requestAudioSessionAuthorization()
        
        if #available(iOS 10.0, *) {
            AudioDataManager.requestSpeechAuthorization()
        }
        
        AudioDataManager.initConnection()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    /// Views
    
    func setupPlayButton() {
        playButton.backgroundColor = UIColor.white
        playButton.layer.cornerRadius = 20.0
        playButton.layer.shadowColor = UIColor.lightGray.cgColor
        playButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        playButton.layer.shadowRadius = 10.0
        playButton.layer.shadowOpacity = 0.3
    }
    
    /// Update text of buttons and labels
    
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
    func updateRecordButton(title: PromptText.RecordButtonTitle) {
        
        recordButton.setTitle(title.rawValue, for: .normal)
    }
    func updatePlayButton(title: PromptText.PlayButtonTitle) {
        
        playButton.setTitle(title.rawValue, for: .normal)
    }
    
    ///
    
    func showRecordPromptContainerView() {
        
        tableView.isUserInteractionEnabled = false
        playButton.isEnabled = true
        sendButton.isEnabled = true
        
        updateRecordButton(title: .cancel)
        updatePlayButton(title: .stop)
        updateRecordingStateLabel(text: .finish)
        updateRecordingTimeIntervalLable(timeInterval: 0.0)
        
        actionsContainerView.setCornerRadius(radius: 20.0, animated: true)

        UIView.animate(withDuration: 0.1) {
            
            self.actionsSepatatorView.alpha = 1.0
        }
        
        UIView.animate(withDuration: 0.5) {
            self.sendButtonWidthConstraint.constant = 80.0
            self.actionsContainerWidthConstraint.constant = 160.0
            self.actionsBottomConstraint.constant = 288.0
            
            self.view.layoutIfNeeded()
        }
    }
    
    func hideRecordPromptContainerView() {
        
        tableView.isUserInteractionEnabled = true
        playButton.isEnabled = false
        sendButton.isEnabled = false
        
        updateRecordButton(title: .begin)

        actionsContainerView.setCornerRadius(radius: 40.0, animated: true)

        UIView.animate(withDuration: 0.1) {
            
            self.actionsSepatatorView.alpha = 0.0
        }
        
        UIView.animate(withDuration: 0.4) {
            self.sendButtonWidthConstraint.constant = 0.0
            self.actionsContainerWidthConstraint.constant = 80.0
            self.actionsBottomConstraint.constant = 8.0
            
            self.view.layoutIfNeeded()
            
        }
    }
    
    
    
    func glance(data: AudioData) {
        
        recordState = .glancing
        
        showRecordPromptContainerView()
        
        dataManager.currentData = data
        
        updatePlayButton(title: .play)
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
        
        hideRecordPromptContainerView()
    }
    
    func sendARecording(data: AudioData) {
        
        AudioDataManager.upload(data: data, progression: { (p) in
            
            print(self, #function, p)
            
        }) { (f) in
            
            print(self, #function, f)
        }
    }
    
    func canRecord() -> Bool {
        return AudioRecorder.canRecord()
    }
        
    func play(record: AudioData, completion: ( (AudioPlayer, Bool) -> () )? = nil) {
        
        dataManager.play(record: record, completion: completion)
    }
    
    func stopPlaying() {
        
        dataManager.stopPlaying()
    }
    
    /// Start to record a new data
    
    func startRecording() {
        
        recordState = .recording
        
        showRecordPromptContainerView()
        
        DispatchQueue.main.async(execute: __startRecording)
    }
    
    func __startRecording() {
        
        dataManager.currentData = nil
        
        let name = "\(Date.currentName).wav"
        let localURL = AudioDataManager.dataURL(with: name)
        
        recorder.startRecording(filename: name, storageURL: localURL)
    }
    
    /// Cancel the recording
    
    func cancelRecording() {
        
        recorder.cancelRecording()
    }
    
    /// Stop the recording
    
    func stopRecording() {
        
        recorder.stopRecording()
    }
    
    /// Record button
    
    
    /* User can tap record button at any state.
     When recordState is .idle, begin a recording, otherwise, cancel that operation
     */
    @IBAction func didTapRecordButton(_ sender: UIButton) {
        
        if !canRecord() {
            return print(#function, "can not record")
        }
        
        switch recordState {
            
        case .idle: return startRecording()
            
        case .recording: cancelRecording()
            
        case .playing: stopPlaying()
            
        case .holding, .glancing: break
        }
        
        recordState = .idle
        
        hideRecordPromptContainerView()
    }
    
    
    @IBAction func didTapPlayButton(_ sender: UIButton) {
        
        switch recordState {
        
        case .holding, .glancing:
            
            if let data = dataManager.currentData {
                
                recordState = .playing

                updateRecordingStateLabel(text: .playing)
                updatePlayButton(title: .stop)
                
                /// start playing a record
                
                play(record: data, completion: { (p, f) in
                    self.recordState = .holding
                    
                    self.updateRecordingStateLabel(text: f ? .finish : .playfail)
                    self.updatePlayButton(title: .play)
                })
            } else {
                
                updateRecordingStateLabel(text: .playfail)
            }
            
            return
            
        case .recording: stopRecording()
            
        case .playing: stopPlaying()
            
        default: break
        }
        
        recordState = .holding
        
        updateRecordingStateLabel(text: .finish)
        updatePlayButton(title: .play)
    }
    
    @IBAction func didTapSendButton(_ sender: UIButton) {
        
        switch recordState {
            
        case .recording: DispatchQueue.main.async { self.recorder.stopRecording() }
            
        case .playing: player.stopPlaying()
            
        default: break
        }
        
        hideRecordPromptContainerView()
        
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
        
        cell.textLabel?.text = data.recordDate.recordDescription
        
        cell.detailTextLabel?.text = data.duration.dateDescription()
        
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label: UILabel = {
            let v = UILabel()
            v.text = "已录制"
            v.font = UIFont.systemFont(ofSize: 26)
            v.textColor = .black
            return v
        }()
        
        return label
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
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








