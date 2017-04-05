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
            guard
                let data = data,
                error == nil,
                let http = response as? HTTPURLResponse,
                http.statusCode == 200,
                let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                let userinfo = jsonObj as? [String:Any],
                let deviceid = userinfo["deviceid"] as? String,
                let id = userinfo["id"] as? Int else {
                    completion(false)
                    return
            }
            
            let user = VGUser(username: username, password: password, deviceID: deviceid, id: id)
            
            VGUserDefaultValue.currentUser = user
            
            completion(true)

        }
    }
    
    // MARK: - 注册
    
    // 注册
    func register(username: String, password: String, deviceID: String, completion: @escaping (Bool) -> Void ) {
        
        VGNetwork.default.register(username: username, password: password, deviceid: deviceID) { (data, response, error) in
            if let _ = data, error == nil, let http = response as? HTTPURLResponse, http.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
