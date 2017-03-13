//
//  ListenViewController.swift
//  VGClient
//
//  Created by jie on 2017/3/10.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

class ListenViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var waveView: WaveView!
    
    fileprivate var audioOperator: AudioOperator!

    
    deinit {
        print(self, #function)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupAudioOperatorAsRecorder()
        
        let name = "\(Date.currentName).wav"
        
        let localURL = FileManager.dataURL(with: name)
        
        let start = audioOperator.startRecording(filename: name, storageURL: localURL)
        
        if !start {
            return print(self, #function)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        waveView.waveLevel = nil
        
        audioOperator.cancelRecord()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func close() {
        
        dismiss(animated: true, completion: nil)
    }
    
    func setupAudioOperatorAsRecorder() {
        
        if let audioOperator = audioOperator {
            audioOperator.releaseResource()
            self.audioOperator = nil
        }
        
        audioOperator = AudioOperator(averagePowerReport: { [weak self] (_, power) in
            
            guard let sself = self, sself.waveView.waveLevel == nil else {
                return
            }
            
            sself.waveView.waveLevel = { () -> Float in
                
                return pow(10, power / 40.0)
            }
            
        }, timeIntervalReport: { (_, time) in
            
            
            
        }, completionHandler: { (_, _, data) in
            
            print(self, #function, "complete")
            
        }, failureHandler: { (_, error) in
            
            print(self, #function, error?.localizedDescription ?? "unknown record error")
        })
    }

}
