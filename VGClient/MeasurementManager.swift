//
//  MeasurementManager.swift
//  VGClient
//
//  Created by viwii on 2017/4/6.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation


final class MeasurementManager {
    
    static let `default` = MeasurementManager()
    
    private init() {  }
    
    
    // MARK: -
    
    func integrate(handler: () -> Void) {
        VGNetwork.default.integrate { (data, response, error) in
            print(self, #function, data ?? "no data", response ?? "no res", error?.localizedDescription ?? "no err des")
        }
    }
    
    func range(type: MeasurementType, fromDate: String, toDate: String, handler: () -> Void) {
        
    }
    
    
}
