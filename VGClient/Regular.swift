//
//  Regular.swift
//  VGClient
//
//  Created by viwii on 2017/3/27.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation


/// 使用正则表达式匹配一个字符串
///
public func evaluate(regular: String, matching text: String) -> Bool {
    
    return NSPredicate(format: "SELF MATCHES %@", regular).evaluate(with: text)
}
