//
//  UserManager.swift
//  VGClient
//
//  Created by viwii on 2017/3/25.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import LocalAuthentication


public final class UserManager: NSObject {
    
    public static let `default` = UserManager()
    
    private override init() {
        super.init()
        
        
    }
    
    public var currentUser: VGUser? {
        
        return VGUserDefaultValue.currentUser
    }
    
    
    // MARK: - 登录
    
    // 登录
    public func login(username: String, password: String, completion: @escaping (Bool) -> Void ) {
        
        /// 假装服务器返回的信息
        let deviceID = "#ffea324eadcf3"
        
        let user = VGUser(username: username, password: password, deviceID: deviceID)
        
        /// 保存
        VGUserDefaultValue.currentUser = user
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { 
            
            completion(true)
        }
    }
    
    // 指纹认证
    @available(iOS 8.0, *)
    public func touchIDAuthenticate(complete: @escaping (Bool, Error?) -> Void ) {
        
        let context = LAContext()
        let result = "请验证您的身份"
        var error: NSError?
        
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: result, reply: complete)
        } else {
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: result, reply: complete)
        }
    }
    
    
    
    // MARK: - 注册
    
    // 注册
    public func register(username: String, password: String, deviceID: String, completion: @escaping (Bool) -> Void ) {
        
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            completion(true)
        }
    }
}
