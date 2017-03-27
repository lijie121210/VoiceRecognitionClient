//
//  UITextField+Regular.swift
//  VGClient
//
//  Created by viwii on 2017/3/27.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UIKit


public extension UITextField {
    
    
    /// 当前的输入是否可以作为一个密码
    public var isPasswordText: Bool {
        
        guard let text = self.text else { return false }
        
        let psregular = "^[a-zA-Z0-9_]{6,20}$"
        
        return evaluate(regular: psregular, matching: text)
    }
    
    
    /// 当前的输入是否可以作为一个用户名
    public var isUsernameText: Bool {
        
        guard let text = self.text else { return false }
        
        let usregular = "^[a-zA-Z0-9_-]{3,20}$"
        
        return evaluate(regular: usregular, matching: text)
    }

    
    
    public var isDeviceIDText: Bool {
        
        guard let text = self.text else { return false }
        
        let idregulat = "^[A-F0-9]{6,20}$"
        
        return evaluate(regular: idregulat, matching: text)
    }
    
    /// 当前两个的输入是否一样
    public func textEqual(to other: UITextField) -> Bool {
        
        return text == other.text
    }
}
