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
        
        guard let item: MThresholdItem = fetch.first else { return nil }
        
        return item
    }
}
