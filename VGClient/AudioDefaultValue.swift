//
//  AudioDefaultValue.swift
//  VGClient
//
//  Created by jie on 2017/3/6.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

///
//public struct AudioDefaultKeyPath: OptionSet {
//    
//    public let rawValue: UInt
//    
//    public init(rawValue: UInt) {
//        self.rawValue = rawValue
//    }
//    
//    public static let isHiddenBackgroundImage = AudioDefaultKeyPath(rawValue: 1<<0)
//    public static let speechRecognitionEngine = AudioDefaultKeyPath(rawValue: 1<<1)
//    
//    public static let all: AudioDefaultKeyPath = [.isHiddenBackgroundImage, .speechRecognitionEngine]
//}

/// 两种识别引擎
enum SpeechRecognitionEngine: Int {
    
    case siri
    
    case hmm
}

/// 使用UserDefaults本地存储用户简单设置
///
struct AudioDefaultValue {
    
    /// 设置发生改变时的通知名称
    /// 使用rawValue作为键值；使用name作为通知名称
    enum KeyPath: String, Equatable {
        
        case setting = "setting"
    
        case isHiddenBackgroundImage = "isHiddenBackgroundImage"
        
        case speechRecognitionEngine = "SpeechRecognitionEngine"
        
        var name: NSNotification.Name {
            return NSNotification.Name(rawValue: self.rawValue)
        }
    }
    
    /// 设置项目

    static var speechRecognitionEngine: SpeechRecognitionEngine {
        
        get {
            let setting = UserDefaults.standard
            
            if
                let val = setting.value(forKey: KeyPath.speechRecognitionEngine.rawValue),
                let raw = val as? Int,
                let engine = SpeechRecognitionEngine(rawValue: raw) {
                
                return engine
            }
            
            /// 保存默认值
            
            UserDefaults.standard.set(SpeechRecognitionEngine.hmm.rawValue, forKey: KeyPath.speechRecognitionEngine.rawValue)
            UserDefaults.standard.synchronize()
            
            /// 默认使用hmm
            return SpeechRecognitionEngine.hmm
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: KeyPath.speechRecognitionEngine.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    static var isHiddenBackgroundImage: Bool {
        
        get {
            let setting = UserDefaults.standard
            
            if
                let val = setting.value(forKey: KeyPath.isHiddenBackgroundImage.rawValue),
                let hidden = val as? Bool {
                return hidden
            }
            
            /// 保存默认值

            UserDefaults.standard.set(true, forKey: KeyPath.isHiddenBackgroundImage.rawValue)
            UserDefaults.standard.synchronize()
            
            /// 默认不显示背景图片
            return true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: KeyPath.isHiddenBackgroundImage.rawValue)
            UserDefaults.standard.synchronize()
        }
        
    }
    
    
}
