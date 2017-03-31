//
//  MasterViewController+DataSource.swift
//  VGClient
//
//  Created by jie on 2017/3/13.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UIKit

extension MasterViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.monitoringInfoCollectionView {
            
            return (DataManager.default.fake_data[0] as AnyObject).count
        }
        
        if collectionView == self.dataCurveCollectionView {
            
            return (DataManager.default.fake_data[1] as AnyObject).count
        }
        
        if collectionView == self.accessoryCollectionView {
            
            return (DataManager.default.fake_data[2] as AnyObject).count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == monitoringInfoCollectionView {
            
            /// monitoring information collection view
            
            let data = (DataManager.default.fake_data[0] as! [MeasurementData])[indexPath.item]
            
            let micell = collectionView.dequeueReusableCell(withReuseIdentifier: "MInfoCell", for: indexPath) as! MInfoCell
            
            micell.imageView.image = data.itemImage
            
            micell.titleLabel.text = data.itemType.textDescription
            
            micell.timeLabel.text = data.updateDate
            
            micell.valueLabel.text = String(data.value)
            
            micell.unitLabel.text = data.itemUnit.rawValue
            
            return micell
            
        } else if collectionView == dataCurveCollectionView {
            
            /// data curve collection view
            
            let data = (DataManager.default.fake_data[1] as! [MeasurementCurveData])[indexPath.item]
            
            let dccell = collectionView.dequeueReusableCell(withReuseIdentifier: "DataCurveCell", for: indexPath) as! DataCurveCell
                        
            dccell.update(data: data)
            
            return dccell
            
        } else {
            
            let data = (DataManager.default.fake_data[2] as! [AccessoryData])[indexPath.item]
            
            let accell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(AccessoryCell.self)", for: indexPath) as! AccessoryCell
            
            accell.update(data: data, delegate: self)
            
            /// 编辑状态
            
            accell.alpha = isEditing ? 0.6 : 1.0
            
            return accell
            
        }
        
    }
    
}
