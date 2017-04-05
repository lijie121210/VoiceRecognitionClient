//
//  User.swift
//  VGClient
//
//  Created by viwii on 2017/3/25.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation


/// Returns a Boolean value indicating whether two values are equal.
///
/// Equality is the inverse of inequality. For any values `a` and `b`,
/// `a == b` implies that `a != b` is `false`.
///
/// - Parameters:
///   - lhs: A value to compare.
///   - rhs: Another value to compare.
func ==(lhs: VGUser, rhs: VGUser) -> Bool {
    return lhs.username == rhs.username && lhs.password == rhs.password && lhs.deviceID == rhs.deviceID
}


/// `Type` define
/// 代表一个登录用户
///

struct VGUser: Equatable {
    
    var id: Int? = nil
    
    let username: String
    
    let password: String
    
    let deviceID: String
    
    init(username: String, password: String, deviceID: String, id: Int? = nil) {
        self.username = username
        self.password = password
        self.deviceID = deviceID
        self.id = id
    }
    
}




/// 管理用户的本地存储
///
public struct VGUserDefaultValue {
    
    static let currentUserKey = "KTYlpek89UIK"
    
    static var currentUser: VGUser? {
        get {
            /// 解析
            guard
                let val = UserDefaults.standard.value(forKey: currentUserKey) as? Data,
                let json = try? JSONSerialization.jsonObject(with: val, options: .mutableContainers),
                let dic = json as? [String : Any],
                let username = dic["username"] as? String,
                let password = dic["password"] as? String,
                let deviceID = dic["deviceID"] as? String,
                let id = dic["id"] as? Int else {
                    return nil
            }
            
            /// 创建返回
            return VGUser(username: username, password: password, deviceID: deviceID, id: id)
        }
        set {
            
            /// 设置nil，清除数据
            guard let newValue = newValue, let id = newValue.id else {
                
                UserDefaults.standard.set(nil, forKey: currentUserKey)
                UserDefaults.standard.synchronize()
                
                return
            }
            
            /// 非nil，保存数据
            let dic: [String:Any] = [
                "username":newValue.username,
                "password":newValue.password,
                "deviceID":newValue.deviceID,
                "id":id]
            
            /// 序列化
            let json = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            
            /// 保存
            UserDefaults.standard.set(json, forKey: currentUserKey)
            UserDefaults.standard.synchronize()
        }
    }
    
}














