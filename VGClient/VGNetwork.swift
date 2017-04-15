//
//  VGNetwork.swift
//  VGClient
//
//  Created by viwii on 2017/4/5.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation


final class VGNetwork: NSObject {
    
    // MARK: - Properties
    
    private let request: VGRequest
    
    var hostname: String {
        return request.hostname
    }
    
    
    // MARK: - singlon instance
    
    static var `default` = VGNetwork()
    
    private override init() {
        // "10.164.54.125"
        request = VGRequest(hostname: "https://aqueous-falls-99981.herokuapp.com")
        super.init()
    }
    
    
    // MARK: - Api
    
    func login(username: String, password: String, completionHandler: @escaping VGRequestHandler) {
        let dic = ["username":username, "password":password]
        let data: Data
        do {
            data = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        } catch {
            completionHandler(nil, nil, VGRequestError.badParameters)
            return
        }
        
        request.post(route: .login, httpBody: data, handler: completionHandler)
    }
    
    func register(user: VGUser, completionHandler: @escaping VGRequestHandler) {
        do {
            let data = try user.data(besideID: true)
            request.post(route: .register, httpBody: data, handler: completionHandler)
        } catch {
            completionHandler(nil, nil, VGRequestError.badParameters)
            return
        }
    }
    
    func integrate(completionHandler: @escaping VGRequestHandler) {
        request.get(route: .integrate, handler: completionHandler)
    }
    
    func recent(count: Int, completionHandler: @escaping VGRequestHandler) {
        request.get(route: .recent(count), handler: completionHandler)
    }
    
    func range() {
        
    }
}
