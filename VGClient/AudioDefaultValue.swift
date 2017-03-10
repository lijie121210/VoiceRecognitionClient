//
//  AudioDefaultValue.swift
//  VGClient
//
//  Created by jie on 2017/3/6.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

/// 设置项目
///
public struct AudioDefaultKeyPath: OptionSet {
    
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static let isHiddenBackgroundImage = AudioDefaultKeyPath(rawValue: 1<<0)
    public static let speechRecognitionEngine = AudioDefaultKeyPath(rawValue: 1<<1)
    
    public static let all: AudioDefaultKeyPath = [.isHiddenBackgroundImage, .speechRecognitionEngine]
}


/// 使用UserDefaults本地存储用户简单设置
///
class AudioDefaultValue {
    
    /// Shared instance
    static let `default`: AudioDefaultValue = AudioDefaultValue()
    
    private init() { }
    
    /// 设置发生改变时的通知名称
    enum Notify: String, Equatable {
        
        case setting = "setting"
        
        case backgroundImage = "backgroundImage"
        
        case speechRecognitionEngine = "speechRecognitionEngine"
        
        var name: NSNotification.Name {
            return NSNotification.Name(rawValue: self.rawValue)
        }
        
    }
    
    /// 两种识别引擎
    enum SpeechRecognitionEngine: Int {
        case siri
        case hmm
        
        static var key: String {
            return "SpeechRecognitionEngine"
        }
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
            
            UserDefaults.standard.set(SpeechRecognitionEngine.hmm.rawValue, forKey: SpeechRecognitionEngine.key)
            UserDefaults.standard.synchronize()
            
            /// 默认使用hmm
            return SpeechRecognitionEngine.hmm
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: SpeechRecognitionEngine.key)
            UserDefaults.standard.synchronize()
        }
    }
    
    private var isHiddenBackgroundImageKey: String {
        return "isHiddenBackgroundImage"
    }
    
    var isHiddenBackgroundImage: Bool {
        
        get {
            let setting = UserDefaults.standard
            
            if
                let val = setting.value(forKey: isHiddenBackgroundImageKey),
                let hidden = val as? Bool {
                return hidden
            }
            
            UserDefaults.standard.set(true, forKey: isHiddenBackgroundImageKey)
            UserDefaults.standard.synchronize()
            
            /// 默认不显示背景图片
            return true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: isHiddenBackgroundImageKey)
            UserDefaults.standard.synchronize()
        }
        
    }
    
    
}
