//
//  MasterViewController+Layout.swift
//  VGClient
//
//  Created by jie on 2017/3/10.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit


/// 附件视图的布局

extension MasterViewController: AlternateLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, heightForItem atIndexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        
        guard let accdatas = DataManager.default.fake_data[2] as? [AccessoryData] else {
            return 0
        }
        
        return accdatas[atIndexPath.item].type.isSingleActionTypes ? 130 : 170
    }
    
}


/// 另外两个集合视图布局

extension MasterViewController: UICollectionViewDelegateFlowLayout {
    
    /// 计算布局信息
    
    fileprivate var inset: CGFloat {
        return 20.0
    }
    
    func layout(for view: UICollectionView) -> UICollectionViewFlowLayout {
        
        /// dataCurveCollectionView使用的是 UICollectionViewFlowLayout 的子类
        let flow = UICollectionViewFlowLayout()
        
        /// 没有头尾视图
        flow.headerReferenceSize = CGSize.zero
        flow.footerReferenceSize = CGSize.zero
        flow.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        /// one section
        flow.minimumInteritemSpacing = 0.0

        switch view {
            
        case self.monitoringInfoCollectionView:
            
            flow.itemSize = CGSize(width: 240, height: 120)
            
            /// 调整垂直滚动的行间距，水平滚动的列间距；
            flow.minimumLineSpacing = inset
            
        case self.dataCurveCollectionView:
            
            flow.itemSize = CGSize(width: view.frame.width - inset * 2 - 10.0, height: 260)
            
            /// 使得每个图标居中，且两边的能露出来一点
            flow.minimumLineSpacing = inset * 0.5
            
        default:
            print(self, #function, "Maybe Error!")
            break
        }
        
        return flow
    }
    
    /// 代理方法，计算都在函数 func layout(_:, _:) 中完成的
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return layout(for: collectionView).itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return layout(for: collectionView).sectionInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return layout(for: collectionView).minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return layout(for: collectionView).minimumInteritemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return layout(for: collectionView).headerReferenceSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        return layout(for: collectionView).footerReferenceSize
    }
}


