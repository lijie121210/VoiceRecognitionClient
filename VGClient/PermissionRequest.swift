//
//  PermissionRequest.swift
//  VGClient
//
//  Created by viwii on 2017/3/31.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Speech
import UserNotifications

/// 从本地plist文件中读取信息
///
struct PermissionPropertyList {
    
    let microphoneAssets: UIImage
    let microphoneDescription: String
    
    let speechAssets: UIImage
    let speechDescription: String
    
    let notificationAssets: UIImage
    let notificationDescription: String
    
    let checkAssets: UIImage
    let checkDescription: String
    
    init?() {
        
        /// read plist file
        guard let url = Bundle.main.url(forResource: "prdes", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil),
            let result = plist as? [[String:Any]] else {
                return nil
        }
        
        /// get record dictionary
        let recorddic = result.filter { (res) -> Bool in
            if let type = res["type"] as? Int {
                return type == 0
            }
            return false
        }
        
        guard let microphone = recorddic.first else {
            return nil
        }
        
        /// parse record description
        guard let rdes = microphone["description"] as? String,
            let rimgName = microphone["assets"] as? String,
            let rimg = UIImage(named: rimgName) else {
                return nil
        }
        
        microphoneAssets = rimg
        microphoneDescription = rdes.replacingOccurrences(of: "n", with: "\n")
        
        
        /// get speech dictionary
        let speechdic = result.filter { (res) -> Bool in
            if let type = res["type"] as? Int {
                return type == 1
            }
            return false
        }
        
        guard let speech = speechdic.first else {
            return nil
        }
        
        /// parse speech description
        guard let sdes = speech["description"] as? String,
            let simgName = speech["assets"] as? String,
            let simg = UIImage(named: simgName) else {
                return nil
        }
        
        speechAssets = simg
        speechDescription = sdes.replacingOccurrences(of: "n", with: "\n")
        
        let notificationdic = result.filter { (res) -> Bool in
            if let type = res["type"] as? Int {
                return type == 2
            }
            return false
        }
        
        guard let notification = notificationdic.first else {
            return nil
        }
        
        guard let ndes = notification["description"] as? String,
            let nimgName = notification["assets"] as? String,
            let nimg = UIImage(named: nimgName) else {
                return nil
        }
        
        notificationAssets = nimg
        notificationDescription = ndes.replacingOccurrences(of: "n", with: "\n")
        
        /// get check dictionary
        let checkdic = result.filter { (res) -> Bool in
            if let type = res["type"] as? Int {
                return type == -1
            }
            return false
        }
        
        guard let check = checkdic.first else {
            return nil
        }
        
        /// parse speech description
        guard
            let cdes = check["description"] as? String,
            let cimgName = check["assets"] as? String,
            let cimg = UIImage(named: cimgName) else {
                return nil
        }
        
        checkAssets = cimg
        checkDescription = cdes.replacingOccurrences(of: "n", with: "\n")
    }
    
}


struct PermissionDefaultValue {
    
    static let authKey: String = "AUTHORIZATIONKEYFF04"
    
    /// 是否已经显示过申请授权的页面；只显示一次；
    static var isRequestedPermission: Bool {
        get {
            guard let val = UserDefaults.standard.value(forKey: authKey) as? NSNumber else {
                return false
            }
            
            return val.boolValue
        }
        set {
            UserDefaults.standard.set(NSNumber(value: newValue), forKey: authKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    
}


final class PermissionRequest: NSObject {
    
    static let `default`: PermissionRequest = PermissionRequest()
    
    private override init() {
        super.init()
    }
    
    // MARK: - Properties
    
    var isRcordPermitted: Bool {
        return AVAudioSession.sharedInstance().recordPermission() == .granted
    }
    
    @available(iOS 10.0, *)
    var isSpeechPermitted: Bool {
        return SFSpeechRecognizer.authorizationStatus() == .authorized
    }
    
    // MARK: - API
    
    /// 申请录音权限
    func requestRecordPermission(_ handler: @escaping (Bool) -> Swift.Void) {
        
        AVAudioSession.sharedInstance().requestRecordPermission(handler)
    }
    
    
    /// 申请语音识别权限
    @available(iOS 10.0, *)
    func requestSpeechAuthorization(_ handler: @escaping (SFSpeechRecognizerAuthorizationStatus) -> Swift.Void) {
        
        SFSpeechRecognizer.requestAuthorization(handler)
    }
    
    /// 申请通知权限
    func requestNotificationAuthorization(_ handler: @escaping (Bool) -> Swift.Void) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound,.badge]) { (granted, error) in
                handler(granted)
            }
        } else {
            let application = UIApplication.shared
            let settings = UIUserNotificationSettings(types: [.alert,.sound,.badge], categories: nil)
            application.registerUserNotificationSettings(settings)
            /// application.registerForRemoteNotifications()
            handler(true)
        }
    }
}
