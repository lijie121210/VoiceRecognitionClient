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

protocol SwitchRootController {
    
    func shouldSwitchRootControllerToLogin()
    
    func shouldSwitchRootCOntrollerToMaster()
}

extension AppDelegate: SwitchRootController {
    
    /// 切换到主视图控制器
    func shouldSwitchRootCOntrollerToMaster() {
        
        guard let master = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? UINavigationController else {
            return
        }
        
        var window = self.window
        
        if window == nil {
            window = UIWindow(frame: UIScreen.main.bounds)
        }
        
        if let root = window!.rootViewController, root is UINavigationController {
            return
        }
        
        window?.makeKeyAndVisible()
        window?.rootViewController = master
    }

    /// 切换到登录页面
    func shouldSwitchRootControllerToLogin() {
        
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
