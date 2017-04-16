//
//  MainViewController+DataSource.swift
//  VGClient
//
//  Created by viwii on 2017/4/14.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

extension MainViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.measurementCollectionView {
            return latestMeasurements.count
        }        
        if collectionView == self.accessoryCollectionView {
            return (DataManager.default.fake_data[2] as AnyObject).count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == measurementCollectionView {
            /// measurement collection view
            let data = latestMeasurements[indexPath.item]
            let mcell = collectionView.dequeueReusableCell(withReuseIdentifier: "MeasurementCCell", for: indexPath) as! MeasurementCCell
            mcell.imageView.image = data.itemImage
            mcell.titleLabel.text = data.itemType.textDescription
            mcell.timeLabel.text = data.updateDate
            mcell.valueLabel.text = String(format: "%.2f", data.value)
            mcell.unitLabel.text = data.itemUnit.rawValue
            
            if let item = MThresholdManager.default.threshold(accordingTo: data) {
                mcell.rangeView.lowText = "\(item.low)"
                mcell.rangeView.highText = "\(item.high)"
                
                switch data.value {
                case -40..<item.low         : mcell.rangeView.maskPosition = -1
                case item.low...item.high   : mcell.rangeView.maskPosition = 0
                case item.high...100        : mcell.rangeView.maskPosition = 1
                default                     : mcell.rangeView.maskPosition = 2
                }
            } else {
                mcell.rangeView.lowText = "--"
                mcell.rangeView.highText = "--"
                mcell.rangeView.maskPosition = 0
            }
            
            return mcell
        } else {
            /// accessory collection view
            let data = (DataManager.default.fake_data[2] as! [AccessoryData])[indexPath.item]
            let accell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(AccessoryCell.self)", for: indexPath) as! AccessoryCell
            accell.update(data: data, delegate: self)
            
            /// 编辑状态
            accell.alpha = isEditing ? 0.6 : 1.0
            
            return accell
        }
    }
}
