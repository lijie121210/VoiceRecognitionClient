//
//  VGDefaultValue.swift
//  VGClient
//
//  Created by viwii on 2017/4/20.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UIKit



extension Notification.Name {
   
    static let setting = Notification.Name(VGDefaultValue.KeyPath.setting)
    
    static let isHiddenBackgroundImage = Notification.Name(VGDefaultValue.KeyPath.isHiddenBackgroundImage)
    
    static let speechRecognitionEngine = Notification.Name(VGDefaultValue.KeyPath.speechRecognitionEngine)
    
    static let currentUserKey = Notification.Name(VGDefaultValue.KeyPath.currentUserKey)
    
    
}



/// 两种识别引擎
enum SpeechRecognitionEngine: Int {
    
    case siri
    
    case hmm
}


/// 使用UserDefaults本地存储用户简单设置
///
struct VGDefaultValue {
    
    struct KeyPath {
        
        static let setting = "setting"
        
        static let isHiddenBackgroundImage = "isHiddenBackgroundImage"
        
        static let speechRecognitionEngine = "SpeechRecognitionEngine"
        
        static let currentUserKey = "KTYlpek89UIK"
    }
    
    /// 设置项目
    
    static var speechRecognitionEngine: SpeechRecognitionEngine {
        get {
            let setting = UserDefaults.standard
            if
                let val = setting.value(forKey: KeyPath.speechRecognitionEngine),
                let raw = val as? Int,
                let engine = SpeechRecognitionEngine(rawValue: raw) {
                return engine
            }
            /// 保存默认值
            UserDefaults.standard.set(SpeechRecognitionEngine.hmm.rawValue, forKey: KeyPath.speechRecognitionEngine)
            UserDefaults.standard.synchronize()
            
            /// 默认使用hmm
            return SpeechRecognitionEngine.hmm
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: KeyPath.speechRecognitionEngine)
            UserDefaults.standard.synchronize()
        }
    }
    
    static var isHiddenBackgroundImage: Bool {
        get {
            let setting = UserDefaults.standard
            if
                let val = setting.value(forKey: KeyPath.isHiddenBackgroundImage),
                let hidden = val as? Bool {
                return hidden
            }
            /// 保存默认值
            UserDefaults.standard.set(true, forKey: KeyPath.isHiddenBackgroundImage)
            UserDefaults.standard.synchronize()
            
            /// 默认不显示背景图片
            return true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: KeyPath.isHiddenBackgroundImage)
            UserDefaults.standard.synchronize()
        }
        
    }
    
    /// 管理用户的本地存储
    
    static var currentUser: VGUser? {
        get {
            /// 解析
            guard let data = UserDefaults.standard.value(forKey: KeyPath.currentUserKey) as? Data else {
                return nil
            }
            /// 创建返回
            return try? VGUser(data: data)
        }
    }
    
    static func save(user data: Data?) {
        if let data = data {
            UserDefaults.standard.set(data, forKey: KeyPath.currentUserKey)
        } else {
            UserDefaults.standard.set(nil, forKey: KeyPath.currentUserKey)
        }
        UserDefaults.standard.synchronize()
    }
    
}
