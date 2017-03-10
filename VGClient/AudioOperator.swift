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


/// pcm little-endian 16khz 16bit mono
fileprivate let AudioSettings: [String: AnyObject] = [AVLinearPCMIsFloatKey: NSNumber(value: false),
                                                  AVLinearPCMIsBigEndianKey: NSNumber(value: false),
                                                  AVLinearPCMBitDepthKey: NSNumber(value: 16),
                                                  AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),
                                                  AVNumberOfChannelsKey: NSNumber(value: 1),
                                                  AVSampleRateKey: NSNumber(value: 16000),
                                                  AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.high.rawValue)]

///
public class AudioOperator: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    /// hold the timer for updating recorder / player meters.
    fileprivate var updatingTimer: DispatchSourceTimer?
    fileprivate var recorder: AVAudioRecorder?
    fileprivate var player: AVAudioPlayer?

    public var isRecording: Bool {
        if let r = recorder {
            return r.isRecording
        } else {
            return false
        }
    }
    
    public var isPlaying: Bool {
        if let p = player {
            return p.isPlaying
        } else {
            return false
        }
    }
    
    public var filename: String? = nil
    public var endTime: TimeInterval = 0.0
    
    /// Get information about the operation via Block
    public var averagePowerReport: ((AudioOperator, Float) -> ())?
    public var timeIntervalReport: ((AudioOperator, TimeInterval) -> ())?
    public var failureHandler: ((AudioOperator, Error?) -> ())?
    public var completionHandler: ((AudioOperator, Bool, AudioData?) -> ())?
    
    /// Get information about the operation via Observer keypath
    public var currentTime: TimeInterval = 0.0
    public var currentPower: Float = 0.0
    public var startTime: TimeInterval = 0.0
    
    deinit {
        print(self, #function)
    }
    
    func releaseResource() {
        
        averagePowerReport = nil
        timeIntervalReport = nil
        failureHandler = nil
        completionHandler = nil
        
        updatingTimer?.cancel()
        updatingTimer = nil
        
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
}



extension AudioOperator {
    
    convenience init(averagePowerReport: ((AudioOperator, Float) -> ())? = nil, timeIntervalReport: ((AudioOperator, TimeInterval) -> ())? = nil, completionHandler: ((AudioOperator, Bool, AudioData?) -> ())? = nil, failureHandler: ((AudioOperator, Error?) -> ())? = nil) {
        self.init()
        self.averagePowerReport = averagePowerReport
        self.timeIntervalReport = timeIntervalReport
        self.completionHandler = completionHandler
        self.failureHandler = failureHandler
    }
}



/// Updating meters of recorder or player
extension AudioOperator {
    
    public var isUpdatingTimerCancelled: Bool {
        if let timer = updatingTimer {
            return timer.isCancelled
        }
        return true
    }
    
    /// event runs on a background thread, and wakes those delegate or blocks on main thread.
    fileprivate func startUpdating(eventHandler: DispatchWorkItem) {
        /// cancel existed timer
        if let _ = updatingTimer {
            stopUpdating()
        }
        
        /// create new timer
        let event = eventHandler
        let queue = DispatchQueue(label: "com.vg.mointor", attributes: .concurrent)
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.scheduleRepeating(deadline: .now(), interval: .milliseconds(200), leeway: .milliseconds(50))
        timer.setEventHandler(handler: event)
        
        /// start the timer
        timer.resume()
        
        /// hold the timer
        updatingTimer = timer
    }
    
    /// cancel updating if need
    fileprivate func stopUpdating() {
        updatingTimer?.cancel()
        updatingTimer = nil
    }
    
    /// abstract updating method
    fileprivate func sendAction(power: Float, time: TimeInterval) {
        
        self.timeIntervalReport?(self, time)
        self.averagePowerReport?(self, power)
        
        self.currentTime = time
        self.currentPower = power
    }
}



/// Handle recording
extension AudioOperator {
    
    /** event handler for recording.
     update values of currentTime and currentPower.
     trigger timeIntervalReport and averagePowerReport.
     */
    fileprivate func updatingRecordEventHandler() {
        
        let r = self.recorder!
        
        if !r.isRecording {
            return print(self, #function, "r.isRecording == false")
        }
        
        /// call to refresh meter values.
        r.updateMeters()
        
        /// dispatch on main queue.
        DispatchQueue.main.async {
            self.sendAction(power: r.averagePower(forChannel: 0), time: r.currentTime)
        }
    }
    
    /** Start a recording.
     At this time, you should have set delegate or block to get information.
     */
    @discardableResult
    public func startRecording(filename: String, storageURL: URL) -> Bool {
        print(self, #function, "filename: <\(filename)> url: <\(storageURL)>")
        
        stopRecording()
        
        /// create a recorder
        do {
            recorder = try AVAudioRecorder(url: storageURL, settings: AudioSettings)
        } catch {
            print(self, #function, error.localizedDescription)
            return false
        }
        recorder!.delegate = self
        recorder!.isMeteringEnabled = true
        
        if !recorder!.record() {
            return false
        }
        
        startTime = Date().timeIntervalSince1970
        
        startUpdating(eventHandler: DispatchWorkItem(block: updatingRecordEventHandler ))
        
        self.filename = filename
        
        return true
    }
    
    /// Stop a recording.
    /// This method will be the last time to set attribute value,
    /// after that, it will stop the recorder and trigger the delegate method of the recorder.
    public func stopRecording() {
        
        guard let r = recorder, r.isRecording else {
            return
        }
        
        /// set attribute value finally.
        endTime = Date().timeIntervalSince1970
        currentTime = r.currentTime
        
        /// this will trigger delegate methods
        r.stop()
        
        stopUpdating()
    }
    
    /// call for cancelling
    public func cancelRecord() {
        
        guard let r = recorder, r.isRecording else {
            return
        }
        /// this ensures that when calling stop(), the delegate will not trigger
        r.delegate = nil
        /// will not send message to delegate
        r.stop()
        /// remove the file if necessary
        r.deleteRecording()
        
        stopUpdating()
    }
    
    @discardableResult
    public static func delete(recordedItem localURL: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: localURL)
            return true
        } catch {
            print(#function, "Fail to remove. <\(error.localizedDescription)>")
            return false
        }
    }
    
    /// call on Interruption
    fileprivate func cancelRecordIfNeed() {
        
        guard let r = recorder else {
            return
        }
        /// this ensures that when calling stop(), the delegate will not trigger
        r.delegate = nil
        /// will not send message to delegate
        r.stop()
        /// remove the file if necessary
        r.deleteRecording()
        
        stopUpdating()
    }
    
    // AVAudioRecorderDelegate
    
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        guard let name = filename, flag else {
            DispatchQueue.main.async { self.failureHandler?(self, nil) }
            return
        }
        
        let data = AudioData(filename: name, duration: currentTime, recordDate: Date(timeIntervalSince1970: startTime))
        
        DispatchQueue.main.async { self.completionHandler?(self, true, data) }
    }
    
    public func audioRecorderBeginInterruption(_ recorder: AVAudioRecorder) {
        
        cancelRecordIfNeed()
        
        DispatchQueue.main.async { self.failureHandler?(self, nil) }
    }
    
    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        
        DispatchQueue.main.async { self.failureHandler?(self, error) }
    }
}



/// Handle playing
extension AudioOperator {
    
    /** Event handler for playing
     */
    fileprivate func updatingPlayEventHandler() {
        
        let p = self.player!
        
        if !p.isPlaying {
            return
        }
        
        if !p.isMeteringEnabled {
            p.isMeteringEnabled = true
        }
        
        /// call to refresh meter values.
        p.updateMeters()
        
        /// dispatch on main queue.
        DispatchQueue.main.async {
            self.sendAction(power: p.averagePower(forChannel: 0), time: p.currentTime)
        }
    }
    
    func startPlaying(url: URL) -> Bool {
        
        stopPlaying()
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
        } catch {
            print(self, #function, error.localizedDescription)
            return false
        }
        player!.delegate = self
        
        if !player!.play() {
            print(self, #function, "fail to play")
            return false
        }
        
        startUpdating(eventHandler: DispatchWorkItem(block: updatingPlayEventHandler))
        
        return true
    }
    
    /// This method will not trigger audioPlayerDidFinishPlaying(_:, _:)
    public func stopPlaying() {
        
        guard let p = player, p.isPlaying else {
            return
        }
        
        p.stop()
        
        stopUpdating()        
    }
    
    /// call on Interruption
    fileprivate func cancelPlayIfNedd() {
        
        if let p = player {
            /// this ensures that when calling stop(), the delegate will not trigger
            p.delegate = nil
            /// will not send message to delegate
            p.stop()
        }
        
        stopUpdating()
    }
    
    /// AVAudioPlayerDelegate
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        DispatchQueue.main.async { self.completionHandler?(self, flag, nil) }
    }
    
    public func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        
        cancelPlayIfNedd()
        
        DispatchQueue.main.async { self.failureHandler?(self, nil) }
    }
    
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
        DispatchQueue.main.async { self.failureHandler?(self, error) }
    }
}


/// Adding convenience methods
public extension AudioOperator {
    
    /// Set AVAudioSession active or inactive.
    
    /// Note that activating an audio session is a synchronous (blocking) operation
    public static func activeAudioSession(completion: ((Bool) -> ())? = nil) {
        
        let item = DispatchWorkItem {
            var result = false
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
                result = true
            } catch {
                print(self, #function, error.localizedDescription)
            }
            completion?(result)
        }
        
        /// dispatch on global queue.
        DispatchQueue.global().async(execute: item)
    }
    
    public static func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, with: .notifyOthersOnDeactivation)
        } catch {
            return print(self, #function, error.localizedDescription)
        }
    }
    
    /// check record permission
    public static var canRecord: Bool {
        return AVAudioSession.sharedInstance().recordPermission() == .granted
    }
    
    public static func requestAudioSessionAuthorization(completion: ((Bool) -> ())? = nil) {
        if AVAudioSession.sharedInstance().recordPermission() == .granted {
            return
        }
        AVAudioSession.sharedInstance().requestRecordPermission { (permission) in
            
            completion?(permission)
        }
    }
}


/// Handle speech recognization
@available(iOS 10.0, *)
public extension AudioOperator {
    
    /// 检查此刻在此设备上siri是否可用
    public static var isSiriServiceAvailable: Bool {
        if SFSpeechRecognizer.authorizationStatus() != .authorized {
            return false
        }
        guard let recognizer = SFSpeechRecognizer() else {
            return false
        }
        return recognizer.isAvailable
    }
    
    /// 权限申请
    public static func requestSpeechAuthorization(completion: ((Bool) -> ())? = nil) {
        if SFSpeechRecognizer.authorizationStatus() == .authorized {
            return
        }
        SFSpeechRecognizer.requestAuthorization { (status) in
            
        }
    }
    
    /// 使用siri语音识别
    public static func recognize(speech url: URL, progression: ((String?) -> ())? = nil, completion: @escaping (String?) -> () ) {
        
        guard let recognizer = SFSpeechRecognizer() else {
            
            print(self, #function, "speech recognizer can not use in current locale.")
            
            completion(nil)
            
            return
        }
        if !recognizer.isAvailable {
            
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
