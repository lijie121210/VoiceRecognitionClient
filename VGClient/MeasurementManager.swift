//
//  MeasurementManager.swift
//  VGClient
//
//  Created by viwii on 2017/4/6.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UIKit

final class MeasurementManager {
    
    static let `default` = MeasurementManager()
    
    private init() {  }
    
    
    // MARK: - Properties
    
    var dataSource: MeasurementDataSource = MeasurementDataSource()
    
    var accessories: [AccessoryData] = []
    
    // MARK: - api
    
    func initialLoading(handler: @escaping (Bool) -> Void) {
        recent(count: 5, handler: handler)
    }
    
    func recent(count: Int, handler: @escaping (Bool) -> Void) {
        VGNetwork.default.recent(count: count) { (data, response, error) in
            guard let data = data, error == nil, let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                handler(false)
                return
            }
            do {
                self.dataSource = try MeasurementDataSource(from: data)
                handler(true)
            } catch {
                handler(false)
            }
        }
    }
    
    func integrate(handler: @escaping ([MeasurementData]) -> Void) {
        VGNetwork.default.integrate { (data, response, error) in
            guard let data = data, error == nil, let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                return handler([])
            }
            do {
                let res = try MeasurementData.makeIntegratedMeasurements(from: data)
                handler( res )
            } catch {
                handler([])
            }
        }
    }
    
    func range(type: MeasurementType, fromDate: String, toDate: String, handler: () -> Void) {
        
    }
    
    
    // MARK: - Helper
    
    
    
}
