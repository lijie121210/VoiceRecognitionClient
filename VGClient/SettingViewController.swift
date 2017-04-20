//
//  SettingViewController.swift
//  VGClient
//
//  Created by jie on 2017/3/9.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

/// 设置更改后的代理对象
protocol SettingViewControllerDelegate: class {
    
    func setting(controller: SettingViewController, didChangeValueOf keyPath: String, to newValue: Any)
}

let SettingViewControllerDidTapCheckRecordListKey = "svcdtcrlk"

/// 单例的设置界面；
/// self.presentingViewController会被视为代理对象；
///
/// `Note` this class use as a view only.
/// It will not trigger viewWillAppear or viewDidAppear
class SettingViewController: UIViewController {

    // MARK: -

    @IBOutlet weak var containerView: RectCornerView!
    
    @IBOutlet weak var checkRecordList: ArrowControl!
    
    @IBOutlet weak var isHiddenBackgroundImageSwitch: UISwitch!
    
    @IBOutlet weak var speechRecognitionEngineSegmentedControl: UISegmentedControl!
    
    
    // MARK: -
    
    static let `default`: SettingViewController = UIStoryboard(name: "Setting", bundle: nil)
                                                    .instantiateInitialViewController() as! SettingViewController
    
    weak var delegate: SettingViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isHiddenBackgroundImageSwitch.isOn = VGDefaultValue.isHiddenBackgroundImage
        
        speechRecognitionEngineSegmentedControl.selectedSegmentIndex = VGDefaultValue.speechRecognitionEngine.rawValue
        
        /// 设置siri的可用性；
        if #available(iOS 10.0, *), AudioOperator.isSiriServiceAvailable {
            speechRecognitionEngineSegmentedControl.setEnabled(true, forSegmentAt: 0)
        } else {
            speechRecognitionEngineSegmentedControl.setEnabled(false, forSegmentAt: 0)
        }
    }
    
    
    /// 改变了背景设置
    @IBAction func isHiddenBackgroundImageSwitchValueDidChange(_ sender: Any) {
        
        guard let switcher = sender as? UISwitch else {
            return
        }
        
        /// 修改本地存储值
        VGDefaultValue.isHiddenBackgroundImage = switcher.isOn
        
        /// 发送广播
        NotificationCenter.default.post(name: .isHiddenBackgroundImage,
                                        object: nil,
                                        userInfo: [VGDefaultValue.KeyPath.isHiddenBackgroundImage : switcher.isOn])
        
        self.delegate?.setting(controller: self, didChangeValueOf: VGDefaultValue.KeyPath.isHiddenBackgroundImage, to: switcher.isOn)
    }
    
    /// 改变了语音识别引擎设置
    @IBAction func speechRecognitionEngineSegmentedControlValueDidChange(_ sender: Any) {
        guard let segmentedControl = sender as? UISegmentedControl,
            let engine = SpeechRecognitionEngine(rawValue: segmentedControl.selectedSegmentIndex)
            else {
                return
        }
        
        /// 设置成功的代码块
        let saveSetting = {
            /// 修改本地存储值
            VGDefaultValue.speechRecognitionEngine = engine
            
            /// 发送广播
            NotificationCenter.default.post(name: .speechRecognitionEngine,
                                            object: nil,
                                            userInfo: [VGDefaultValue.KeyPath.speechRecognitionEngine : engine.rawValue])
            
            self.delegate?.setting(controller: self, didChangeValueOf: VGDefaultValue.KeyPath.speechRecognitionEngine, to: engine.rawValue)
        }
        
        saveSetting()
    }
    
    @IBAction func didTapCheckRecordList(_ sender: Any) {
        print(self, #function)
        self.dismiss(animated: true) { 
            self.delegate?.setting(controller: self, didChangeValueOf: SettingViewControllerDidTapCheckRecordListKey, to: true)
        }
    }
    
    
    @IBAction func didTapCancelSettingButton(_ sender: Any) {
        dismiss()
    }

    @IBAction func didTapOnView(_ sender: Any) {
        guard
            let c = self.containerView,
            let tap = sender as? UITapGestureRecognizer,
            tap.location(in: c).y < 0.0
        else { return }
        
        dismiss()
    }
    
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
        
        NotificationCenter.default.post(name: .setting, object: nil, userInfo: nil)
    }
}
