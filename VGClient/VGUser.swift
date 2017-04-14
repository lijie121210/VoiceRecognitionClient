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
    return
        lhs.username == rhs.username && lhs.password == rhs.password &&
        lhs.deviceid == rhs.deviceid && lhs.id == rhs.id && lhs.email == rhs.email
}


/// `Type` define
/// 代表一个登录用户
///

struct VGUser: Equatable {
    
    var id: Int? = nil
    
    let username: String
    
    let password: String
    
    let deviceid: String
    
    var email: String?
    
    init(username: String, password: String, deviceid: String, id: Int? = nil, email: String?) {
        self.username = username
        self.password = password
        self.deviceid = deviceid
        self.id = id
        self.email = email
    }
    
}

extension VGUser{
    
    init(data: Data) throws {
        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        
        guard
            let userinfo = json as? [String:Any],
            let username = userinfo["username"] as? String,
            let password = userinfo["password"] as? String,
            let deviceid = userinfo["deviceid"] as? String else {
                throw VGError.badParameter
        }
        
        self.username = username
        self.password = password
        self.deviceid = deviceid
        self.email = userinfo["email"] as? String
        self.id = userinfo["id"] as? Int
    }
}




/// 管理用户的本地存储
///
public struct VGUserDefaultValue {
    
    static let currentUserKey = "KTYlpek89UIK"
    
    static var currentUser: VGUser? {
        get {
            /// 解析
            guard let data = UserDefaults.standard.value(forKey: currentUserKey) as? Data else {
                return nil
            }
            
            /// 创建返回
            return try? VGUser(data: data)
        }
    }
    
    static func save(user data: Data?) {
        if let data = data {
            UserDefaults.standard.set(data, forKey: currentUserKey)
        } else {
            UserDefaults.standard.set(nil, forKey: currentUserKey)
        }
        UserDefaults.standard.synchronize()
    }
    
}














