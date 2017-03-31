//
//  RandomNumber.swift
//  VGClient
//
//  Created by jie on 2017/3/13.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation


/// 不包括 to
/// - return : from..<to

func randomInteger(from: Int, to: Int) -> Int {
    
    guard from < to else {
        return 0
    }
    
    var a: UInt32 = 0
    
    arc4random_buf(&a, MemoryLayout<UInt32>.size)
    
    let index = (a % UInt32(to - from)) + UInt32(from)
    
    return Int(index)
}


/// - return : 0...1

func randomFloat() -> Float {
    
    let integer = randomInteger(from: 0, to: 101)
    
    return Float(integer) / 100.0
}
