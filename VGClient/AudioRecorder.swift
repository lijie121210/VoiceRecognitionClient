//
//  AudioRecorder.swift
//  VGClient
//
//  Created by jie on 2017/2/19.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioRecorderDelegate {
    
    /// Calls are very frequent
    func audioRecorder(_ recorder: AudioRecorder, averagePower power: Float)
    
    /// Calls are very frequent
    func audioRecorder(_ recorder: AudioRecorder, timeDuration currentTime: TimeInterval)
    
    /// called when stopped recording , including cancelling
    func audioRecorder(_ recorder: AudioRecorder, isFinished result: (String, Date, TimeInterval)? )
    
    /// called when cancelled recording
    func audioRecorder(_ recorder: AudioRecorder, isCancelled reason: String)
}


private let AudioSettings: [String: AnyObject] = [AVLinearPCMIsFloatKey: NSNumber(value: false),
                                                  AVLinearPCMIsBigEndianKey: NSNumber(value: false),
                                                  AVLinearPCMBitDepthKey: NSNumber(value: 16),
                                                  AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),
                                                  AVNumberOfChannelsKey: NSNumber(value: 1), AVSampleRateKey: NSNumber(value: 16000),
                                                  AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.high.rawValue)]


class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    
    /// set a limit value
    var miniDurationLimit: TimeInterval = 0
    
    /// responsible to release it after using
    var delegate: AudioRecorderDelegate?
    
    var recorder: AVAudioRecorder!
    
    var isRecording: Bool {
        if let r = recorder {
            return r.isRecording
        } else {
            return false
        }
    }
    let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    
    private var startTime: TimeInterval = 0
    private var endTime: TimeInterval = 0
    private var timeInterval: TimeInterval = 0
    private var filename: String? = nil
    private var isCancelled: Bool = false
    
    private var recordDuration: TimeInterval {
        return endTime - startTime
    }
    
    private var isCrossMiniDurationLimit: Bool {
        return (miniDurationLimit > 0 && recordDuration < miniDurationLimit)
    }
    
    private var operationQueue: OperationQueue!
    
    override init() {
        operationQueue = OperationQueue()
        super.init()
    }
    
    convenience init(delegate: AudioRecorderDelegate) {
        self.init()
        
        self.delegate = delegate
    }
    
    @discardableResult
    func activeAudioSession() -> Bool {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
            return true
        } catch {
            print("setCategory fail or setActive fail")
            return false
        }
    }
    
    func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, with: .notifyOthersOnDeactivation)
        } catch {
            return print("setActive fail or read recorder.url")
        }
    }
    
    static func canRecord() -> Bool {
        return AVAudioSession.sharedInstance().recordPermission() == .granted
    }
    
    func createRecorder(at path: URL) -> AVAudioRecorder? {
        do {
            let recorder = try AVAudioRecorder(url: path, settings: AudioSettings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            return recorder
        } catch {
            print("init AVAudioRecorder")
            return nil
        }
    }
    
    /// Dispatch perform
    
    func performRecording(withDelay: TimeInterval) {
        perform(#selector(AudioRecorder.__startRecord),
                with: self,
                afterDelay: withDelay)
    }
    
    func performCancelRecording() {
        NSObject.cancelPreviousPerformRequests(withTarget: self,
                                               selector: #selector(AudioRecorder.__startRecord),
                                               object: self)
    }
    
    
    /// Start a recording
    
    @discardableResult
    func startRecording(filename: String, storageURL: URL) -> Bool {
        
        self.filename = filename
        
        /// reset cancel flag
        isCancelled = false
        
        guard
            activeAudioSession(),
            let r = createRecorder(at: storageURL) else {
                print(#function, "activeAudioSession fail")
                return false
        }
        recorder = r
        recorder.prepareToRecord()
        
        /// schadule recording request
        performRecording(withDelay: 0.25)
        
        return true
    }
    
    func __startRecord() {
        /// start time counting
        startTime = Date().timeIntervalSince1970
        
        recorder.record()
        
        operationQueue.addOperation( BlockOperation(block: updateMeters) )
    }
    
    func updateMeters() {
        repeat {
            recorder.updateMeters()
            
            delegate?.audioRecorder(self, timeDuration: recorder.currentTime)
            
            timeInterval = recorder.currentTime
            
            delegate?.audioRecorder(self, averagePower: recorder.averagePower(forChannel: 0))
            
            Thread.sleep(forTimeInterval: 0.2)
            
        } while(recorder.isRecording)
    }
    
    /// Stop a recording
    func stopRecording() {
        
        endTime = Date().timeIntervalSince1970
        
        timeInterval = recorder.currentTime
        
        recorder.stop()
        
        deactivateAudioSession()
        
        operationQueue.cancelAllOperations()
        
        /// if set miniDurationLimit value, check...
        if isCrossMiniDurationLimit {
            
            timeInterval = 0
            
            recorder.deleteRecording()
        }
    }
    
    /// Cancel a recording
    func cancelRecording() {
        
        if recorder.isRecording {
            
            recorder.stop()
            deactivateAudioSession()
            operationQueue.cancelAllOperations()
        }
        
        timeInterval = 0
        filename = nil
        isCancelled = true
        
        recorder.deleteRecording()
        
        delegate?.audioRecorder(self, isCancelled: "cancelRecording")
    }
    
    // MARK: audio delegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        guard flag, !isCrossMiniDurationLimit, !isCancelled, let name = filename else {
            
            delegate?.audioRecorder(self, isFinished: nil)
            return
        }
        
        delegate?.audioRecorder(self, isFinished: (name, Date(timeIntervalSince1970: startTime), timeInterval: timeInterval))
    }
    
    func audioRecorderBeginInterruption(_ recorder: AVAudioRecorder) {
        
        print("audioRecorderBeginInterruption")
        
        cancelRecording()
    }
    
    func audioRecorderEndInterruption(_ recorder: AVAudioRecorder, withOptions flags: Int) {
        
        print("audioRecorderEndInterruption")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        
        delegate?.audioRecorder(self, isCancelled: error?.localizedDescription ?? "audioRecorderEncodeErrorDidOccur")
        
        guard let e = error else {
            return
        }
        print("audioRecorderEncodeErrorDidOccur, ", e.localizedDescription)
        
    }
    
}
