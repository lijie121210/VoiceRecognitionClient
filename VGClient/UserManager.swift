//
//  UserManager.swift
//  VGClient
//
//  Created by viwii on 2017/3/25.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import LocalAuthentication


final class UserManager: NSObject {
    
    static let `default` = UserManager()
    
    private override init() {
        super.init()
    }
    
    var currentUser: VGUser? {
        
        return VGUserDefaultValue.currentUser
    }
    
    
    // MARK: - 登录
    
    
    // 指纹认证
    @available(iOS 8.0, *)
    func touchIDAuthenticate(complete: @escaping (Bool, Error?) -> Void ) {
        let context = LAContext()
        let result = "请验证您的身份"
        var error: NSError?
        
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: result, reply: complete)
        } else {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: result, reply: complete)
        }
    }
    
    
    // 登录
    func login(username: String, password: String, completion: @escaping (Bool) -> Void ) {

        VGNetwork.default.login(username: username, password: password) { (data, response, error) in
            guard let data = data, error == nil, let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                completion(false)
                return
            }
            do {
                /// 能创建成功，说明数据解析没问题，直接保存数据就好了
                let _ = try VGUser(data: data)
                
                VGUserDefaultValue.save(user: data)
                
                completion(true)
            } catch {
                completion(false)
            }
        }
    }
    
    // MARK: - 注册
    
    // 注册
    func register(user: VGUser, completion: @escaping (Bool) -> Void ) {
        
        VGNetwork.default.register(user: user) { (data, response, error) in
            if let _ = data, error == nil, let http = response as? HTTPURLResponse, http.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
