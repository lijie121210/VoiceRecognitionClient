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
    
    func setting(controller: SettingViewController, didChangeValueOf keyPath: AudioDefaultKeyPath, to newValue: Any)
}

/// 单例的设置界面；
/// self.presentingViewController会被视为代理对象；
///
class SettingViewController: UIViewController {
    
    @IBOutlet weak var containerView: RectCornerView!
    
    @IBOutlet weak var isHiddenBackgroundImageSwitch: UISwitch!
    
    @IBOutlet weak var speechRecognitionEngineSegmentedControl: UISegmentedControl!
    
    static let `default`: SettingViewController = UIStoryboard(name: "Setting", bundle: nil)
                                                    .instantiateInitialViewController() as! SettingViewController
    
    // 检查自己的presentingViewController是否实现SettingViewControllerDelegate，如果实现了，则将其视为代理对象；
    weak var delegate: SettingViewControllerDelegate? {
        
        if let c = self.presentingViewController as? SettingViewControllerDelegate {
            return c
        }
        
        return nil
    }
    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        super.unwind(for: unwindSegue, towardsViewController: subsequentVC)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isHiddenBackgroundImageSwitch.isOn = AudioDefaultValue.default.isHiddenBackgroundImage
        
        speechRecognitionEngineSegmentedControl.selectedSegmentIndex = AudioDefaultValue.default.speechRecognitionEngine.rawValue
        
        /// 设置siri的可用性；
        if #available(iOS 10.0, *), AudioOperator.isSiriServiceAvailable {
            speechRecognitionEngineSegmentedControl.setEnabled(true, forSegmentAt: 0)
        } else {
            speechRecognitionEngineSegmentedControl.setEnabled(false, forSegmentAt: 0)
        }
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
        
        NotificationCenter.default.post(name: AudioDefaultValue.Notify.setting.name,
                                        object: nil,
                                        userInfo: nil)
    }
    
    /// 改变了背景设置
    @IBAction func isHiddenBackgroundImageSwitchValueDidChange(_ sender: Any) {
        
        guard let switcher = sender as? UISwitch else {
            return
        }
        
        /// 修改本地存储值
        AudioDefaultValue.default.isHiddenBackgroundImage = switcher.isOn
        
        /// 发送广播
        NotificationCenter.default.post(name: AudioDefaultValue.Notify.backgroundImage.name,
                                        object: nil,
                                        userInfo: ["isHiddenBackgroundImage":switcher.isOn])
        
        self.delegate?.setting(controller: self, didChangeValueOf: AudioDefaultKeyPath.isHiddenBackgroundImage, to: switcher.isOn)
    }
    
    /// 改变了语音识别引擎设置
    @IBAction func speechRecognitionEngineSegmentedControlValueDidChange(_ sender: Any) {
        
        guard
            let segmentedControl = sender as? UISegmentedControl,
            let engine = AudioDefaultValue.SpeechRecognitionEngine(rawValue: segmentedControl.selectedSegmentIndex)
            else {
                return
        }
        
        /// 设置成功的代码块
        let saveSetting = {
            
            /// 修改本地存储值
            AudioDefaultValue.default.speechRecognitionEngine = engine
            
            /// 发送广播
            NotificationCenter.default.post(name: AudioDefaultValue.Notify.speechRecognitionEngine.name,
                                            object: nil,
                                            userInfo: ["speechRecognitionEngine":engine.rawValue])
            
            self.delegate?.setting(controller: self, didChangeValueOf: AudioDefaultKeyPath.speechRecognitionEngine, to: engine.rawValue)
        }
        
        saveSetting()
    }
    
    /// 点击了确定按钮；
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
    
    
}
