//
//  MasterViewController+Action.swift
//  VGClient
//
//  Created by jie on 2017/3/13.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UIKit


extension MasterViewController: UICollectionViewDelegate, AccessoryCellDelegate {
    
    /// 点击了cell
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard var accdatas = DataManager.default.fake_data[2] as? [AccessoryData] else { return }
        
        let i = indexPath.item
        
        var data = accdatas[i]
        
        ///
        
        guard data.type.isSingleActionTypes else { return }
        
        ///
        
        let orbit = OrbitAlertController.show(with: "正在执行...", on: self)
        
        if data.state == .opened {
            data.state = .closed
        } else {
            data.state = .opened
        }
        
        ///
        
        accdatas.replaceSubrange((i..<i+1), with: [data])
        
        DataManager.default.fake_data.replaceSubrange((2..<3), with: [accdatas])
        
        ///
        
        update(collectionView: accessoryCollectionView, indexPaths: [indexPath], orbit: orbit)

    }
    
    
    
    ///  点击了三联操作的某个按钮
    
    func cell(_ cell: AccessoryCell, isTapped action: AccessoryAction) {
        
        guard
            let indexPath = accessoryCollectionView.indexPath(for: cell),
            
            var accdatas = DataManager.default.fake_data[2] as? [AccessoryData] else {
            
                return
        }
        
        let i = indexPath.item
        
        var data = accdatas[i]
        
        ///
        
        guard !data.type.isSingleActionTypes else { return }
        
        ///
        
        let orbit = OrbitAlertController.show(with: "正在执行...", on: self)
        
        ///
        
        switch action {
        case .close: data.state = .closed
        case .stop: data.state = .stopped
        case .open,.timing(_): data.state = .opened
        }
        
        accdatas.replaceSubrange((i..<i+1), with: [data])
        
        DataManager.default.fake_data.replaceSubrange((2..<3), with: [accdatas])
        
        ///
        
        update(collectionView: accessoryCollectionView, indexPaths: [indexPath], orbit: orbit)
        
        
    }
    
    
    fileprivate func update(collectionView: UICollectionView, indexPaths:[IndexPath], orbit: OrbitAlertController?, after: DispatchTime = .now() + 1.0) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            orbit?.update(prompt: "执行成功")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                
                orbit?.dismiss(animated: true, completion: nil)
            })
            
            ///
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                
                collectionView.performBatchUpdates({ 
                                        
                    collectionView.reloadItems(at: indexPaths)

                }, completion: nil)
                
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
