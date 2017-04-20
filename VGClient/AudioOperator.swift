//
//  AudioRecorder.swift
//  VGClient
//
//  Created by jie on 2017/2/19.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import AVFoundation
import Speech


/// 开始录制音频和结束录制音频的广播名称
///
extension Notification.Name {
    
    static let recordbegin = Notification.Name("record did begin")
    
    static let recordend = Notification.Name("record did end")
}





@objc protocol AudioOperatorDelegate: class {
    @objc optional
    func audioOperator(_ audioOperator: AudioOperator, didFinishRecording data: AudioRecordResult)
    
    @objc optional
    func audioOperator(_ audioOperator: AudioOperator, didFailRecording error: Error)
    
    @objc optional
    func audioOperator(_ audioOperator: AudioOperator, recordingTime time: TimeInterval, andPower power: Float)
    
    @objc optional
    func audioOperatorDidFinishPlaying(_ audioOperator: AudioOperator)
    
    @objc optional
    func audioOperator(_ audioOperator: AudioOperator, playingTime time: TimeInterval, andPower power: Float)
}



/// 提供录音，播放功能
final class AudioOperator: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    /// pcm little-endian 16khz 16bit mono
    static let settings = [
        AVLinearPCMIsFloatKey: NSNumber(value: false),
        AVLinearPCMIsBigEndianKey: NSNumber(value: false),
        AVLinearPCMBitDepthKey: NSNumber(value: 16),
        AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),
        AVNumberOfChannelsKey: NSNumber(value: 1),
        AVSampleRateKey: NSNumber(value: 16000),
        AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.high.rawValue)
    ]
    
    // MARK: - Properties

    /// hold the timer for updating recorder / player meters.

    private let queue: DispatchQueue

    fileprivate var updatingTimer: DispatchSourceTimer?
    
    fileprivate var recorder: AVAudioRecorder?
    
    fileprivate var player: AVAudioPlayer?
    
    weak var delegate: AudioOperatorDelegate?
    
    var filename: String?
    var storageURL: URL?
    var startTime: TimeInterval = 0.0
    /// 记录录制时长
    var currentTime: TimeInterval = 0.0

    
    // MARK: - Init
    
    deinit {
        print(self, #function)
    }
    
    override init() {
        
        queue = DispatchQueue(label: "com.vg.mointor")
        
        super.init()
    }
    
    
    static func delete(recordedItem localURL: URL) throws {
        try FileManager.default.removeItem(at: localURL)
    }
    
    // MARK: - Recorder
    
    var isRecording: Bool {
        if let r = recorder {
            return r.isRecording
        } else {
            return false
        }
    }
    
    
    @discardableResult
    func startRecording(filename: String, storageURL: URL) throws -> Bool {
        print(self, #function, "filename: <\(filename)> url: <\(storageURL)>")

        cancelRecording()

        self.filename = filename
        self.storageURL = storageURL

        try AudioOperator.activeAudioSession()
        
        recorder = try AVAudioRecorder(url: storageURL, settings: AudioOperator.settings)
        recorder!.delegate = self
        recorder!.isMeteringEnabled = true
        
        startTime = Date().timeIntervalSince1970
        currentTime = 0.0
        let res = recorder!.record()
        resumeTimer(recordingUpdation)
        return res
    }
    
    /// Stop a recording.
    /// This method will be the last time to set attribute value,
    /// after that, it will stop the recorder and trigger the delegate method of the recorder.
    func stopRecording() {
        suspendTimer()
        if let r = recorder, r.isRecording {
            currentTime = r.currentTime
            r.stop()
        }
        
    }
    
    /// Call for cancelling.
    /// when calling stop(), the delegate will `not` trigger;
    /// `not` send message to delegate;
    /// remove the file if necessary;
    func cancelRecording() {
        suspendTimer()
        if let r = recorder {
            r.delegate = nil
            r.stop()
            r.deleteRecording()
        }
    }
    
    func recordingUpdation() {
        guard let r = recorder, r.isRecording else { return }
        r.updateMeters()
        DispatchQueue.main.async {
            let power = r.averagePower(forChannel: 0)
            let time = r.currentTime
            self.delegate?.audioOperator?(self, recordingTime: time, andPower: power)
        }
    }
    
    
    // MARK: - Player
    
    var isPlaying: Bool {
        if let p = player {
            return p.isPlaying
        } else {
            return false
        }
    }
    
    func startPlaying(url: URL) throws -> Bool {
        stopPlaying()
        player = try AVAudioPlayer(contentsOf: url)
        player!.delegate = self
        resumeTimer(playingUpdation)
        return player!.play()
    }
    
    func stopPlaying() {
        suspendTimer()
        if let p = player {
            p.stop()
        }
    }
    
    func cancelPlaying() {
        suspendTimer()
        if let p = player {
            p.delegate = nil
            p.stop()
        }
    }
    
    func playingUpdation() {
        guard let p = self.player, p.isPlaying == true else { return }
        p.updateMeters()
        DispatchQueue.main.async {
            let power = p.averagePower(forChannel: 0)
            let time = p.currentTime
            self.delegate?.audioOperator?(self, playingTime: time, andPower: power)
        }
    }
    
    
    // MARK: - Helper
    
    /// 是否更新计时器被取消了
    var isUpdatingTimerCancelled: Bool {
        if let timer = updatingTimer {
            return timer.isCancelled
        } else {
            return true
        }
    }
    
    /// Event runs on a background thread,
    /// and wakes those delegate or blocks on main thread.
    func resumeTimer(_ eventHandler: @escaping () -> Void) {
        suspendTimer()
        
        updatingTimer = DispatchSource.makeTimerSource(queue: queue)
        updatingTimer!.scheduleRepeating(deadline: .now(), interval: .milliseconds(500), leeway: .milliseconds(100))
        updatingTimer!.setEventHandler(handler: DispatchWorkItem(block: eventHandler))
        updatingTimer!.resume()
    }
    
    /// Suspend updating timer
    func suspendTimer() {
        updatingTimer?.cancel()
        updatingTimer = nil
    }
    
    func releaseResource() {
        suspendTimer()
        
        if let r = recorder {
            r.delegate = nil
            if r.isRecording {
                r.stop()
            }
            recorder = nil
        }
        if let p = player {
            p.delegate = nil
            if p.isPlaying {
                p.stop()
            }
            player = nil
        }
    }
    
    /// AudioSession
    
    /// Set AVAudioSession active or inactive.
    static func activeAudioSession() throws {
        
        try AVAudioSession.sharedInstance().setActive(true)
        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
    }
    
    /// Set AVAudioSession inactive.
    static func deactivateAudioSession() throws {
        
        try AVAudioSession.sharedInstance().setActive(false, with: .notifyOthersOnDeactivation)
    }
    
    /// Check record permission
    static var canRecord: Bool {
        return AVAudioSession.sharedInstance().recordPermission() == .granted
    }
    
    static func requestAudioSessionAuthorization(completion: ((Bool) -> ())? = nil) {
        if AVAudioSession.sharedInstance().recordPermission() == .granted {
            return
        }
        AVAudioSession.sharedInstance().requestRecordPermission { (permission) in
            
            completion?(permission)
        }
    }
    
    
    // MARK: - AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        DispatchQueue.main.async {
            if let name = self.filename, flag == true {
                let data = AudioRecordResult(filename: name,
                                             duration: self.currentTime,
                                             recordDate: Date(timeIntervalSince1970: self.startTime))
                self.delegate?.audioOperator?(self, didFinishRecording: data)
            } else {
                self.cancelRecording()
                self.delegate?.audioOperator?(self, didFailRecording: VGError.recordFailure)
            }
        }
    }
    
    func audioRecorderBeginInterruption(_ recorder: AVAudioRecorder) {
        cancelRecording()
        DispatchQueue.main.async {
            self.delegate?.audioOperator?(self, didFailRecording: VGError.recordFailure)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        cancelRecording()
        DispatchQueue.main.async {
            self.delegate?.audioOperator?(self, didFailRecording: error ?? VGError.recordFailure)
        }
    }
    
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.delegate?.audioOperatorDidFinishPlaying?(self)
        }
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        cancelPlaying()
        DispatchQueue.main.async {
            self.delegate?.audioOperatorDidFinishPlaying?(self)
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async {
            self.delegate?.audioOperatorDidFinishPlaying?(self)
        }
    }
}

@available(iOS 10.0, *)
extension AudioOperator {
    
    /// 检查此刻在此设备上siri是否可用
    static var isSiriServiceAvailable: Bool {
        if SFSpeechRecognizer.authorizationStatus() != .authorized {
            return false
        }
        guard let recognizer = SFSpeechRecognizer() else {
            return false
        }
        return recognizer.isAvailable
    }
    
    /// 权限申请
    static func requestSpeechAuthorization(completion: @escaping (Bool) -> Void) {
        if SFSpeechRecognizer.authorizationStatus() == .authorized {
            return
        }
        SFSpeechRecognizer.requestAuthorization { (status) in
            completion(status == .authorized)
        }
    }
    
    /// 使用siri语音识别
    static func recognize(speech url: URL, progression: ((String?) -> ())? = nil, completion: @escaping (String?) -> () ) {
        guard let recognizer = SFSpeechRecognizer() else {
            
            print(self, #function, "speech recognizer can not use in current locale.")
            
            completion(nil)
            
            return
        }
        guard recognizer.isAvailable else {
            
            print(self, #function, "speech recognizer is not Available.")
            
            completion(nil)
            
            return
        }
        
        let request = SFSpeechURLRecognitionRequest(url: url)
        
        recognizer.recognitionTask(with: request) { (result: SFSpeechRecognitionResult?, error) in
            
            guard let result = result else {
                
                print(self, #function, error?.localizedDescription ?? "unknown error")
                
                completion(nil)
                
                return
            }
            
            print(self, #function, "result: ", result.bestTranscription.formattedString)
            
            if result.isFinal {
                completion(result.bestTranscription.formattedString)
            } else {
                progression?(result.bestTranscription.formattedString)
            }
        }
        
        
    }
    
    
}

extension AudioOperator {
    static func recognizeHMM(speech url: URL, completion: @escaping (String?) -> () ) {
    }
}
