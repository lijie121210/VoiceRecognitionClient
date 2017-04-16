//
//  MThresholdManager.swift
//  VGClient
//
//  Created by viwii on 2017/4/16.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import CoreData



final class MThresholdManager {
    
    static let `default` = MThresholdManager()
    
    private init() { }
    
    func threshold(accordingTo data: MeasurementData) -> MThresholdItem? {
        guard data.itemType == .airTemperature,
            let time = data.updateDate.dateComponents(),
            let hour = time.hour,
            hour >= 8 || hour <= 20 else {
                return nil
        }
        let fetch: [MThresholdItem] = CoreDataManager.default.fetch()
        
        if let item: MThresholdItem = fetch.first {
            return item
        } else {
            let item = CoreDataManager.default.insertEntity(MThresholdItem.self)
            item.effective_high_time = "20"
            item.effective_low_time = "8"
            item.low = 15
            item.high = 30
            CoreDataManager.default.saveContext()
            return item
        }
    }
}
