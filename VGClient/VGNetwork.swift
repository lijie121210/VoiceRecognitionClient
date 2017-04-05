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
    
    func register(username: String, password: String, deviceid: String, completionHandler: @escaping VGRequestHandler) {
        let dic = ["username":username, "password":password, "deviceid":deviceid]
        let data: Data
        do {
            data = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        } catch {
            completionHandler(nil, nil, VGRequestError.badParameters)
            return
        }
        
        request.post(route: .register, httpBody: data, handler: completionHandler)
    }
}
