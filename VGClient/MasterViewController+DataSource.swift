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
        
        if collectionView == self.accessoryCollectionView {
            return 2
        }
        
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.accessoryCollectionView {
            
            return ((DataManager.default.fake_data[2] as! [Any])[section] as! [AccessoryData]).count
        }
        
        if collectionView == self.monitoringInfoCollectionView {
            
            return (DataManager.default.fake_data[0] as! [MeasurementData]).count
            
        }
        
        if collectionView == self.dataCurveCollectionView {
            
            return (DataManager.default.fake_data[1] as! [MeasurementCurveData]).count
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
            
            dccell.titleLabel.text = data.title
            dccell.dateLabel.text = data.duration
            dccell.unitLabel.text = "单位: " + data.type.unit.rawValue
            
            /// 清除掉原来的图, 绘制新的图形
            
            dccell.update(config: data.config)
                        
            let color = dccell.canvasView.colors[randomInteger(from: 0, to: dccell.canvasView.colors.count)]
            dccell.canvasView.colors = [color]
            
            dccell.canvasView.x.labels.values = data.xlabels
            dccell.canvasView.addLine(data.datas)
            
            return dccell
            
        } else if indexPath.section == 0 {
            
            let data = ((DataManager.default.fake_data[2] as! [Any])[0] as! [AccessoryData])[indexPath.item]
            
            let accell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultiActionCell", for: indexPath) as! MultiActionCell
            
            accell.titlelLabel.text = data.name
            
            accell.imageView.image = data.image
            
            accell.delegate = self
            
            return accell
            
        } else {
            
            let data = ((DataManager.default.fake_data[2] as! [Any])[1] as! [AccessoryData])[indexPath.item]
            
            let accell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleActionCell", for: indexPath) as! SingleActionCell
            
            accell.titleLabel.text = data.name
                        
            accell.imageView.image = data.image
            
            accell.update(status: data.state)
            
            return accell
        }
        
    }
    
}
