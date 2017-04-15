//
//  MasterViewController+Authority.swift
//  VGClient
//
//  Created by viwii on 2017/4/5.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

extension MasterViewController {
    /// 跳转申请权限的界面
    func requestPermission() {
        
        guard let authority = UIStoryboard(name: "Authority", bundle: nil).instantiateInitialViewController() else {
            return
        }
        show(authority, sender: nil)
    }
    
    /// 根据是否申请权限调整界面
    func checkPermissionAppearing() {
        if PermissionDefaultValue.isRequestedPermission {
            scrollView.alpha = 1.0
        } else {
            scrollView.alpha = 0.0
        }
    }
    
    func checkPermissionAppeared() {
        if PermissionDefaultValue.isRequestedPermission {
            /// 去掉注释可以使得设备的集合视图完全显示，而不会滚动。
            expandScrollViewHeight()
            
            MeasurementManager.default.integrate { res in
                print(res)
            }
        } else {
            /// 显示申请授权的页面
            requestPermission()
        }
    }
}
