//
//  AudioDefaultValue.swift
//  VGClient
//
//  Created by jie on 2017/3/6.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

class AudioDefaultValue {
    
    /// Shared instance
    static let `default`: AudioDefaultValue = AudioDefaultValue()
    
    private init() { }
    
    enum SpeechRecognitionEngine: Int {
        case siri
        case hmm
        
        static var key: String {
            return "SpeechRecognitionEngine"
        }
    }
    
    private var isHiddenBackgroundImageKey: String {
        return "isHiddenBackgroundImage"
    }
    
    var speechRecognitionEngine: SpeechRecognitionEngine {
        
        get {
            let setting = UserDefaults.standard
            
            if
                let val = setting.value(forKey: SpeechRecognitionEngine.key),
                let raw = val as? Int,
                let engine = SpeechRecognitionEngine(rawValue: raw) {
                return engine
            }
            
            /// 默认使用siri
            return SpeechRecognitionEngine.siri
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: SpeechRecognitionEngine.key)
        }
    }
    
    var isHiddenBackgroundImage: Bool {
        
        get {
            let setting = UserDefaults.standard
            
            if
                let val = setting.value(forKey: isHiddenBackgroundImageKey),
                let hidden = val as? Bool {
                return hidden
            }
            
            /// 默认不显示背景图片
            return true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: isHiddenBackgroundImageKey)
        }
        
    }
    
    
}
