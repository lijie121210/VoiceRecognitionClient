//
//  ListenViewController.swift
//  VGClient
//
//  Created by jie on 2017/3/10.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

/// 只是显示一个正在录音或者没有录音的状态。
///
/// `Note` this class use as a view only.
/// It will not trigger viewWillAppear or viewDidAppear
class ListenViewController: UIViewController, AudioOperatorDelegate {

    // MARK: - outlet
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet var waveViews: [WaveView]!
    
    // MARK: - Properties
    
    let audioOperator: AudioOperator = AudioOperator()
    
    
    // MARK: - View Controller

    deinit {
        print(self, #function)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "--"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        start()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if audioOperator.isRecording {
            titleLabel.text = "正在聆听"
        } else {
            titleLabel.text = "无法聆听"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        audioOperator.releaseResource()
    }
    
    
    // MARK: - User Interaction
    
    @IBAction func done(_ sender: Any) {
        
        defer {
            dismiss(animated: true, completion: nil)
        }
        
        audioOperator.stopRecording()
    }
    @IBAction func close(_ sender: Any) {
        
        defer {
            dismiss(animated: true, completion: nil)
        }
        
        audioOperator.cancelRecording()
        
        titleLabel.text = "取消"
    }
    
    
    // MARK: - AudioOperatorDelegate
    
    func audioOperator(_ audioOperator: AudioOperator, didFinishRecording data: AudioRecordResult) {
        print(self, #function)
        print(data.filename)
        print(data.duration)
        print(data.recordDate)
        
        titleLabel.text = "完成"
    }
    
    func audioOperator(_ audioOperator: AudioOperator, recordingTime time: TimeInterval, andPower power: Float) {
        
        let level = pow(10, power / 50.0)
        let level2 = pow(10, power / 40.0)
        
        waveViews.forEach { $0.level = $0.tag == 2 ? level : level2 }
    }
    
    func audioOperator(_ audioOperator: AudioOperator, didFailRecording error: Error) {
        titleLabel.text = "无法聆听"
    }
    
    // MARK: - Helper
    
    func start() {
        let name = "listen.wav"
        
        let localURL = FileManager.dataURL(with: name)
        
        do {
            try audioOperator.startRecording(filename: name, storageURL: localURL)
        } catch {
            
        }
    }
}

