//
//  MainViewController+DataSource.swift
//  VGClient
//
//  Created by viwii on 2017/4/14.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

extension MainViewController: UICollectionViewDataSource {
    
    func configMeasurementCCell(_ cell: MeasurementCCell, _ cv: UICollectionView, indexPath: IndexPath) {
        let data = latestMeasurements[indexPath.item]
        cell.imageView.image = data.itemImage
        cell.titleLabel.text = data.itemType.textDescription
        cell.timeLabel.text = data.updateDate
        cell.valueLabel.text = String(format: "%.2f", data.value)
        cell.unitLabel.text = data.itemUnit.rawValue
        
        if let item = MThresholdManager.default.threshold(accordingTo: data) {
            cell.rangeView.lowText = "\(item.low)"
            cell.rangeView.highText = "\(item.high)"
            
            switch data.value {
            case -40..<item.low         : cell.rangeView.maskPosition = -1
            case item.low...item.high   : cell.rangeView.maskPosition = 0
            case item.high...100        : cell.rangeView.maskPosition = 1
            default                     : cell.rangeView.maskPosition = 2
            }
        } else {
            cell.rangeView.lowText = "--"
            cell.rangeView.highText = "--"
            cell.rangeView.maskPosition = 0
        }
    }
    
    func configAccessoryCell(_ cell: AccessoryCell, _ cv: UICollectionView, indexPath: IndexPath) {
        let data = AccessoryManager.default.accessoryDatas[indexPath.item]
        cell.titleLabel.text = data.name
        cell.imageView.image = data.image
        cell.infoLabel.text = data.state.textDescription
//        cell.actionIndicatorImageView.image = UIImage(named: "")
        /// 设置模糊效果的显示和隐藏
        if data.state == .opened {
            cell.container.fillColor = UIColor(white: 1, alpha: 1)
            cell.actionIndicatorImageView.image = UIImage(named: "timer")
        } else {
            cell.container.fillColor = UIColor(white: 0.9, alpha: 0.333)
        }
        if data.isTimed {
            cell.actionIndicatorImageView.image = UIImage(named: "timer")
        } else {
            cell.actionIndicatorImageView.image = UIImage(named: "switcher")
        }
        if data.type.isSingleActionTypes {
            /// 显示点击图标
            cell.actionIndicatorImageView.isHidden = false
            /// 无操作按钮
            cell.actionStack.isHidden = true
            /// 移除代理
            cell.delegate = nil
        } else {
            /// 隐藏点击图标
            cell.actionIndicatorImageView.isHidden = true
            /// 有三个操作按钮
            cell.actionStack.isHidden = false
            /// 设置代理
            cell.delegate = self
        }
        /// 编辑状态
        cell.alpha = isEditing ? 0.6 : 1.0
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.measurementCollectionView {
            return latestMeasurements.count
        }        
        if collectionView == self.accessoryCollectionView {
            return AccessoryManager.default.accessoryDatas.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == measurementCollectionView {
            /// measurement collection view
            let mcell = collectionView.dequeueReusableCell(withReuseIdentifier: MeasurementCCell.reuseid,
                                                           for: indexPath) as! MeasurementCCell
            configMeasurementCCell(mcell, collectionView, indexPath: indexPath)
            return mcell
        } else {
            /// accessory collection view
            let accell = collectionView.dequeueReusableCell(withReuseIdentifier: AccessoryCell.reuseid,
                                                            for: indexPath) as! AccessoryCell
            configAccessoryCell(accell, collectionView, indexPath: indexPath)
            return accell
        }
    }
}
