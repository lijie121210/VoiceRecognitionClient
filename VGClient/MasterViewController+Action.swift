//
//  MasterViewController+Action.swift
//  VGClient
//
//  Created by jie on 2017/3/13.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UIKit


///



extension MasterViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard collectionView == self.accessoryCollectionView else {
            return
        }
        
        
    }
}




///  点击了三联操作的某个按钮

extension MasterViewController: MultiActionCellDelegate {
    
    func cell(_ cell: MultiActionCell, isTapped action: AccessoryAction) {
        
        print(self, #function, action)
    }
    
    
    
}


/// 点击图表上的点，显示一个提示框，1.0s后自动隐藏

extension MasterViewController: LineChartDelegate {
    
    func didSelectDataPoint(_ x: CGFloat, yValues: [CGFloat]) {
        
        let offset = dataCurveCollectionView.contentOffset
        let size = dataCurveCollectionView.frame.size
        let point = CGPoint(x: offset.x + size.width * 0.5, y: offset.y + size.height * 0.5)
        
        guard
            let indexPath = dataCurveCollectionView.indexPathForItem(at: point),
            let cell = dataCurveCollectionView.cellForItem(at: indexPath) as? DataCurveCell else {
                return
        }
        
        UIView.animate(withDuration: 0.5) {
            
            cell.popLabel.isHidden = false
            cell.popLabel.text = "<x: \(x), y: \(yValues.map{ String(describing: $0) }.joined())>"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            UIView.animate(withDuration: 0.5, animations: {
                cell.popLabel.isHidden = true
                cell.popLabel.text = nil
            })
        }
    }
}


/// 向上滚动隐藏user图标；向下显示

extension MasterViewController {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        guard scrollView == self.scrollView else {
            return
        }
        
        if (targetContentOffset.pointee.y - scrollView.contentOffset.y) > 0 {
            /// 手指向上划，向下滚，隐藏
            
            self.userButtonContainer.isHidden = true
        } else {
            
            self.userButtonContainer.isHidden = false
        }
    }
}
