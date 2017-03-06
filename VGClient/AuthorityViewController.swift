//
//  AuthorityViewController.swift
//  VGClient
//
//  Created by jie on 2017/2/20.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

class AuthorityViewController: UIViewController {
    
    @IBOutlet weak var isHiddenBackgroundImageSwitch: UISwitch!

    @IBOutlet weak var speechRecognitionEngineSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0.9, alpha: 0.3)
        
        isHiddenBackgroundImageSwitch.isOn = AudioDefaultValue.default.isHiddenBackgroundImage
        
        speechRecognitionEngineSegmentedControl.selectedSegmentIndex = AudioDefaultValue.default.speechRecognitionEngine.rawValue
    }
    
    @IBAction func isHiddenBackgroundImageSwitchValueDidChange(_ sender: Any) {
        
        guard let master = masterParent, let switcher = sender as? UISwitch else {
            return
        }
        
        AudioDefaultValue.default.isHiddenBackgroundImage = switcher.isOn
        
        master.updateViewFromSettings()
    }
    
    @IBAction func speechRecognitionEngineSegmentedControlValueDidChange(_ sender: Any) {
        
        guard
            let segmentedControl = sender as? UISegmentedControl,
            let engine = AudioDefaultValue.SpeechRecognitionEngine(rawValue: segmentedControl.selectedSegmentIndex)
        else {
                return
        }
        
        AudioDefaultValue.default.speechRecognitionEngine = engine
    }
    
    @IBAction func didTapCancelSettingButton(_ sender: Any) {
        
        guard let master = masterParent else {
            return
        }
        
        master.attemptToCancelSetting()
    }
    

}
