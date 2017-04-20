//
//  ListenViewController.swift
//  VGClient
//
//  Created by jie on 2017/3/10.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

protocol ListenViewControllerDelegate: class {
    func listen(_ vc: ListenViewController, didRecognizedSpeech result: String)
}


/// 只是显示一个正在录音或者没有录音的状态。
///
/// `Note` this class use as a view only.
/// It will not trigger viewWillAppear or viewDidAppear
class ListenViewController: UIViewController, AudioOperatorDelegate {

    // MARK: - outlet
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet var waveViews: [WaveView]!
    
    @IBOutlet weak var retry: RCView!
    
    
    // MARK: - Properties
    
    let audioOperator: AudioOperator = AudioOperator()
    
    var recognizer: Any?
    
    weak var delegate: ListenViewControllerDelegate?
    
    // MARK: - View Controller

    deinit {
        print(self, #function)
        recognizer = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "准备中..."
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startRecording()    
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        audioOperator.releaseResource()
    }
    
    
    // MARK: - User Interaction
    
    @IBAction func done(_ sender: Any) {
        
        audioOperator.stopRecording()
    }
    @IBAction func close(_ sender: Any) {
        
        audioOperator.cancelRecording()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.titleLabel.text = "取消"
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapRetry(_ sender: Any) {
        startRecording()
    }
    
    // MARK: - AudioOperatorDelegate
    
    func audioOperator(_ audioOperator: AudioOperator, didFinishRecording data: AudioRecordResult) {
        titleLabel.text = "正在识别..."
        
        recognize(record: data)
    }
    
    func audioOperator(_ audioOperator: AudioOperator, recordingTime time: TimeInterval, andPower power: Float) {
        let level = pow(10, power / 50.0)
        let level2 = pow(10, power / 40.0)
        
        waveViews.forEach { $0.level = $0.tag == 2 ? level : level2 }
        
        if time > 50 {
            titleLabel.text = "时长请不要超过1分钟"
        }
        retry.text = time.minutesDescription
    }
    
    func audioOperator(_ audioOperator: AudioOperator, didFailRecording error: Error) {
        titleLabel.text = "无法聆听"
    }
    
    // MARK: - Helper
    
    func startRecording() {
        if audioOperator.isRecording {
            titleLabel.text = "取消"
            audioOperator.cancelRecording()
        }
        
        start()
        
        if audioOperator.isRecording {
            titleLabel.text = "正在聆听"
            retry.text = "00:00"
            retry.isUserInteractionEnabled = false
        } else {
            titleLabel.text = "无法聆听"
            retry.text = "再试一试"
            retry.isUserInteractionEnabled = true
        }
    }
    
    func start() {
        
        audioOperator.delegate = self
        
        let name = "listen.wav"
        
        let localURL = FileManager.dataURL(with: name)
        
        do {
            try audioOperator.startRecording(filename: name, storageURL: localURL)
        } catch {
            titleLabel.text = "无法启用录音"
        }
    }
    
    func recognize(record: AudioRecordResult) {
        let url = record.localURL
        
        if #available(iOS 10.0, *) {
            let reg = AudioRecognizer(url: url)
            reg.recognize(completion: { (text, result) in
                self.recognized(result: text)
                
                /// Now everything is here, save it to db.
                
                let item = CoreDataManager.default.insertEntity(AudioRecordItem.self)
                item.recordDate = record.recordDate as NSDate
                item.duration = record.duration
                item.data = record.data as NSData?
                item.translation = text
                item.url = record.localURL.absoluteString
                CoreDataManager.default.saveContext()
            })
            
            recognizer = reg

        } else {
            AudioOperator.recognizeHMM(speech: url) { text in
                
            }
        }
    }
    
    func recognized(result: String?) {
        DispatchQueue.main.async {
            if let text = result {
                self.delegate?.listen(self, didRecognizedSpeech: text)
            } else {
                self.titleLabel.text = "无法识别"
                self.retry.isUserInteractionEnabled = true
                self.retry.text = "再试一试"
            }
        }
    }
}

