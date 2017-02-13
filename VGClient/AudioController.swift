//
//  AudioController.swift
//  VGClient
//
//  Created by jie on 2017/2/12.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import AVFoundation
import CoreData


/******************************** Audio text ***********************************/


/// Create a file name from current date

extension Date {
    
    static var currentName: String {
        
        let formatterString = DateFormatter.localizedString(from: Date(),
                                                            dateStyle: .short,
                                                            timeStyle: .long)
        
        let res = formatterString.replacingOccurrences(of: " ", with: "a")
            .replacingOccurrences(of: "/", with: "b")
            .replacingOccurrences(of: "+", with: "c")
            .replacingOccurrences(of: ":", with: "d")
            .replacingOccurrences(of: ",", with: "e")
        
        return res
    }
}


extension TimeInterval {
    
    /// 用迭代重写!
    
    func dateDescription() -> String {
        
        if self < 0 {
            return "--:--"
        }
        
        let _d: TimeInterval = 24 * 60 * 60
        let _h: TimeInterval = 60 * 60
        let _m: TimeInterval = 60
        let _s: TimeInterval = 1
        
        var res = ""
        
        var v = self
        
        var dx: Int = Int(v / _d)
        
        if dx >= 10 {
            res.append("\(dx)天 ")
        } else if dx > 0 {
            res.append("0\(dx)天 ")
        }
        
        /// handle hour
        
        v = v - TimeInterval(dx) * _d
        
        dx = Int(v / _h)
        
        if dx < 10 {
            res.append("0\(dx):")
        } else {
            res.append("\(dx):")
        }
        
        /// handle minute
        
        v = v - TimeInterval(dx) * _h
        
        dx = Int(v / _m)
        
        if dx < 10 {
            res.append("0\(dx):")
        } else {
            res.append("\(dx):")
        }
        
        /// handle second
        
        v = v - TimeInterval(dx) * _m
        
        dx = Int(v / _s)
        
        if dx < 10 {
            res.append("0\(dx)")
        } else {
            res.append("\(dx)")
        }
        
        return res
    }
    
}



/******************************** Audio record data ***********************************/


struct AudioDataManager {
    
    var datas: [AudioData] = []
    
    var currentData: AudioData? = nil
    
    mutating func loadLocalData() {
        
        var result = [AudioRecordItem]()
        
        let request = NSFetchRequest<AudioRecordItem>(entityName: "AudioRecordItem")
        let context = CoreDataManager.default.managedObjectContext
        
        context.performAndWait {
            do {
                result = try context.fetch( request )
            } catch {
                print(#function, error.localizedDescription)
            }
        }
        let resultDatas = result.map {
            return AudioData(dataURL: URL(string: $0.localURL!)!, duration: $0.duration,recordDate: $0.createDate as! Date)
        }
        
        datas.append(contentsOf: resultDatas)
    }
    
    mutating func append(newData: (URL, Date, TimeInterval)?) {
        
        let data = updateCurrentData(newData: newData)

        if let d = data {
            datas.append(d)
            
            CoreDataManager.default.append(data: d)
        }
    }
    
    
    @discardableResult
    mutating func updateCurrentData(newData: (URL, Date, TimeInterval)?) -> AudioData? {
        var data: AudioData? = nil
        
        if let r = newData {
            data = AudioData(dataURL: r.0, duration: r.2, recordDate: r.1)
        }
        
        currentData = data
        
        return data
    }
    
    @discardableResult
    mutating func remove(at index: Int) -> Bool {
        
        guard index >= 0, index < datas.count else {
            return false
        }

        let data = datas[index]
        
        do {
            try FileManager.default.removeItem(at: data.dataURL)
        } catch {
            print(#function, "Fail to remove. <\(error.localizedDescription)>")
            return false
        }
        
        CoreDataManager.default.remove(data: data)

        datas.remove(at: index)
        
        return true
    }
    
    
    @discardableResult
    mutating func removeLast() -> AudioData {
        return datas.removeLast()
    }
    
    
}

extension AudioDataManager {

    static let dataDirectoryName = "audio_record_files"

    static var dataStorageDirectory: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent(dataDirectoryName)
    }
    
    static func initAudioDataStorageDirectory() {
        if FileManager.default.fileExists(atPath: dataStorageDirectory.path) {
            return
        }
        do {
            try FileManager.default.createDirectory(at: dataStorageDirectory, withIntermediateDirectories: false, attributes: nil)
        } catch {
            print(#function, error.localizedDescription)
        }
    }
    
    static func newDataURL(with fileName: String) -> URL {
        return dataStorageDirectory.appendingPathComponent(fileName)
    }
}

struct AudioData: Equatable {
    
    let dataURL: URL
    let duration: TimeInterval
    let recordDate: Date
    
    var translation: String? = nil
    
    var data: Data? {
        return try? Data(contentsOf: dataURL)
    }
    
    init(dataURL: URL, duration: TimeInterval, recordDate: Date) {
        self.dataURL = dataURL
        self.duration = duration
        self.recordDate = recordDate
    }
}

func ==(lhs: AudioData, rhs: AudioData) -> Bool {
    return lhs.dataURL == rhs.dataURL && lhs.duration == rhs.duration && lhs.recordDate == rhs.recordDate
}


/******************************** AudioRecorder ***********************************/



protocol AudioRecorderDelegate {
    
    /// Calls are very frequent
    func audioRecorder(_ recorder: AudioRecorder, averagePower power: Float)
    
    /// Calls are very frequent
    func audioRecorder(_ recorder: AudioRecorder, timeDuration currentTime: TimeInterval)
    
    /// called when stopped recording , including cancelling
    func audioRecorder(_ recorder: AudioRecorder, isFinished result: (URL, Date, TimeInterval)? )
    
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
    func startRecording(at storageURL: URL) -> Bool {
        /// reset cancel flag
        isCancelled = false
        
        /// create new recorder
        guard let r = createRecorder(at: storageURL) else {
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
            
            operationQueue.cancelAllOperations()
        }
        
        timeInterval = 0
        
        isCancelled = true
        
        recorder.deleteRecording()
        
        delegate?.audioRecorder(self, isCancelled: "cancelRecording")
    }
    
    // MARK: audio delegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        guard flag, !isCrossMiniDurationLimit, !isCancelled else {
            
            delegate?.audioRecorder(self, isFinished: nil)
            return
        }
        
        delegate?.audioRecorder(self, isFinished: (recorder.url, Date(timeIntervalSince1970: startTime), timeInterval: timeInterval))
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




/******************************** AudioPlayer ***********************************/



class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    
    static let sharedPlayer: AudioPlayer = AudioPlayer()
    
    var player: AVAudioPlayer!
    
    private var completionHandler: ( (AudioPlayer, Bool) -> () )? = nil
    
    private override init() {
        super.init()
    }
    
    func startPlaying(url: URL, completion: ( (AudioPlayer, Bool) -> () )? = nil) {
        
        if (player != nil && player.isPlaying) {
            stopPlaying()
        }
        
        completionHandler = completion
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategorySoloAmbient)
            
            player = try AVAudioPlayer(contentsOf: url)
        } catch{
            return print("AudioPlayer: initilization error or set session category")
        }
        
        player.delegate = self
        player.play()
    }
    
    /// This method will not trigger audioPlayerDidFinishPlaying(_:, _:)
    func stopPlaying() {
        player.stop()
        player.delegate = nil
        player = nil
        completionHandler = nil
    }
    
    /// AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("audioPlayerDidFinishPlaying flag:", flag)
        
        defer {
            completionHandler = nil
        }
        
        guard let handler = completionHandler else {
            return
        }
        
        DispatchQueue.main.async {
            handler(self, flag)
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
        guard let e = error else {
            return
        }
        print("audioRecorderEncodeErrorDidOccur, ", e.localizedDescription)
    }
}
