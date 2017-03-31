//
//  UIViewController+Warning.swift
//  VGClient
//
//  Created by viwii on 2017/3/27.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    /// 显示错误信息
    /// 未做是否已经展示模态的检查
    /// - parameter message: 提示信息内容
    public func warning(message: String, style: UIAlertControllerStyle = .alert, sourceView: UIView? = nil) {
        
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: style)
        
        let action = UIAlertAction(title: "确定", style: .default, handler: nil)
        
        alert.addAction(action)
        
        alert.popoverPresentationController?.sourceView = sourceView
        
        self.present(alert, animated: true, completion: nil)
    }
    
    public func warning(duration: TimeInterval, message: String, style: UIAlertControllerStyle = .actionSheet, sourceView: UIView? = nil, completion: (() -> Swift.Void)? = nil) {
        
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: style)
        
        alert.popoverPresentationController?.sourceView = sourceView ?? view
        
        present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { 
            alert.dismiss(animated: true, completion: completion)
        }
    }
}
