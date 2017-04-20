//
//  AccessoryManager.swift
//  VGClient
//
//  Created by viwii on 2017/4/18.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UIKit

final class AccessoryManager {
    
    static let `default` = AccessoryManager()
    
    private init() {  }
    
    var accessoryDatas: [AccessoryData] = [
        AccessoryData(type: .rollingMachine, state: .opened, name: "1号卷帘机"),
        AccessoryData(type: .wateringPump, state: .opened, name: "1号浇灌泵"),
        AccessoryData(type: .fillLight, state: .opened, name: "1号补光灯"),
        AccessoryData(type: .fillLight, state: .opened, name: "2号补光灯"),
        AccessoryData(type: .warmingLamp, state: .closed, name: "1号增温灯"),
        AccessoryData(type: .warmingLamp, state: .closed, name: "2号增温灯"),
        AccessoryData(type: .ventilator, state: .opened, name: "1号通风机"),
        AccessoryData(type: .ventilator, state: .opened, name: "2号通风机")
    ]
    
    func insertAtFront(_ data: AccessoryData) -> Bool {
        if accessoryDatas.contains(data) {
            return false
        }
        
        accessoryDatas.insert(data, at: 0)
        
        return true
    }
    
    func replace(_ data: AccessoryData, at index: Int) -> Bool {
        if accessoryDatas.contains(data) {
            return false
        }
        
        accessoryDatas.replaceSubrange((index..<index+1), with: [data])
        
        return true
    }
    
    func remove(_ data: AccessoryData) -> Bool {
        guard let index = accessoryDatas.index(of: data) else {
            return false
        }
        
        accessoryDatas.remove(at: index)
        
        return true
    }
}
