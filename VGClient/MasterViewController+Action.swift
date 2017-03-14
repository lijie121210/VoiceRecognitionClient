//
//  MasterViewController+Action.swift
//  VGClient
//
//  Created by jie on 2017/3/13.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UIKit



extension MasterViewController {
    
    /// 点击了附件编辑与添加的事件
    
    //    var isEditing: Bool
    
    @IBAction func didTapAccessoryEditButton(_ sender: Any) {
        
        
        if isEditing {
            
            isEditing = false
            
            accessoryEditButton.setImage(UIImage(named: "edit"), for: .normal)
            
            /// 除了在这里修改，还要在代理方法里面做判断
            
            for cell in accessoryCollectionView.visibleCells {
                
                cell.alpha = 1
            }
            
        } else {
            
            isEditing = true
            
            accessoryEditButton.setImage(UIImage(named: "done"), for: .normal)
            
            for cell in accessoryCollectionView.visibleCells {
                
                cell.alpha = 0.6
            }
        }
        
    }
    
    @IBAction func didTapAccessoryAddButton(_ sender: Any) {
        
        /// auto perform segue
    }
    
    
    
}



extension MasterViewController: UICollectionViewDelegate, AccessoryCellDelegate {
    
    /// 点击了cell
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard var accdatas = DataManager.default.fake_data[2] as? [AccessoryData] else { return }
        
        let i = indexPath.item
        
        var data = accdatas[i]
        
        
        /// 编辑
        
        if collectionView == accessoryCollectionView, isEditing {
            
            let id = "\(AccessoryViewController.self)"
                        
            performSegue(withIdentifier: id, sender: ["editing":true, "indexPath": indexPath, "data":data])
                        
            return
        }
        
        
        /// 操作
        
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


extension MasterViewController: AccessoryOperationDelegate {
    
    func accessoryViewController(_ controller: AccessoryViewController, attemptToAdd data: AccessoryData) {
        
        guard var accdatas = DataManager.default.fake_data[2] as? [AccessoryData] else {
            
            return
        }
        
        accdatas.insert(data, at: 0)
        
        DataManager.default.fake_data.replaceSubrange((2..<3), with: [accdatas])
        
        accessoryCollectionView.performBatchUpdates({
            
            self.accessoryCollectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
            
        }, completion: nil)
    }
    
    func accessoryViewController(_ controller: AccessoryViewController, attemptToEdit data: AccessoryData, at indexPath: IndexPath?) {
        
        guard var accdatas = DataManager.default.fake_data[2] as? [AccessoryData], let i = indexPath?.item else {
                
                return
        }
        
        accdatas.replaceSubrange((i..<i+1), with: [data])
        
        DataManager.default.fake_data.replaceSubrange((2..<3), with: [accdatas])
        
        accessoryCollectionView.performBatchUpdates({
            
            self.accessoryCollectionView.reloadItems(at: [indexPath!])
            
        }, completion: nil)
        

    }
    
    func accessoryViewController(_ controller: AccessoryViewController, attemptToDelete data: AccessoryData, at indexPath: IndexPath?) {
        
        guard var accdatas = DataManager.default.fake_data[2] as? [AccessoryData], let i = indexPath?.item else {
            
            return
        }
        
        accdatas.remove(at: i)
        
        DataManager.default.fake_data.replaceSubrange((2..<3), with: [accdatas])
        
        accessoryCollectionView.performBatchUpdates({
            
//            self.accessoryCollectionView.reloadItems(at: [indexPath!])
            
            self.accessoryCollectionView.deleteItems(at: [indexPath!])
            
        }, completion: nil)
        
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
