//
//  AppDelegate+Root.swift
//  VGClient
//
//  Created by viwii on 2017/3/26.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UIKit

/// AppDelegate extension : switch root view controller of key window

public protocol SwitchRootController {
    
    func shouldSwitchRootControllerToLogin()
    
    func shouldSwitchRootCOntrollerToMaster()
}

extension AppDelegate: SwitchRootController {
    
    /// 切换到主视图控制器
    public func shouldSwitchRootCOntrollerToMaster() {
        
        guard let master = UIStoryboard(name: "Master", bundle: nil).instantiateInitialViewController() as? MasterViewController else {
            return
        }
        
        var window = self.window
        
        if window == nil {
            window = UIWindow(frame: UIScreen.main.bounds)
        }
        
        if let root = window!.rootViewController, root is MasterViewController {
            return
        }
        
        window?.makeKeyAndVisible()
        window?.rootViewController = master
    }

    /// 切换到登录页面
    public func shouldSwitchRootControllerToLogin() {
        
        guard let login = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController() as? LoginViewController else {
            return
        }
        
        var window = self.window
        
        if window == nil {
            window = UIWindow(frame: UIScreen.main.bounds)
        }
        
        if let root = window!.rootViewController, root is LoginViewController {
            return
        }
        
        window?.makeKeyAndVisible()
        window?.rootViewController = login
    }

    
    
}
