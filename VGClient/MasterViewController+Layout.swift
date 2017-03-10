//
//  MasterViewController+Layout.swift
//  VGClient
//
//  Created by jie on 2017/3/10.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

/// 给三个集合视图布局
extension MasterViewController: UICollectionViewDelegateFlowLayout {
    
    /// 计算布局信息
    
    func layout(for view: UICollectionView, on section: Int = 0) -> UICollectionViewFlowLayout {
        
        /// 几个地方用到这些同样的值
        let inset: CGFloat = 20.0
        let w = view.frame.size.width - inset * 3
        
        let flow = UICollectionViewFlowLayout()
        
        /// 没有头尾视图
        flow.headerReferenceSize = CGSize.zero
        flow.footerReferenceSize = CGSize.zero
        
        /// 除了accessoryCollectionView，其他都是水平单行
        flow.minimumInteritemSpacing = 0.0
        
        flow.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        flow.minimumLineSpacing = inset
        
        switch (view, section) {
        
        case (self.accessoryCollectionView, 0):
            
            flow.itemSize = CGSize(width: w - view.contentOffset.x * 2 - 8, height: 100)
            
            /// 单列，多行
            flow.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: 0.0, right: inset)

            flow.minimumInteritemSpacing = 10.0
            
        case (self.accessoryCollectionView, 1):
            
            flow.itemSize = CGSize(width: (w - inset) * 0.5 - 2, height: 100)
            
            /// 两列，多行
            flow.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)

            flow.minimumInteritemSpacing = 10.0
            
        case (self.dataCurveCollectionView, 0):
            
            /// dataCurveCollectionView使用的是 UICollectionViewFlowLayout 的子类
            
            flow.itemSize = CGSize(width: w, height: 260)
            
            /// 使得每个图标居中，且两边的能露出来一点
            flow.minimumLineSpacing = 10.0
            
        case (self.monitoringInfoCollectionView, 0):
            
            flow.itemSize = CGSize(width: 200, height: 120)
            
        default:
            print(self, #function, "Maybe Error!")
            break
        }
        
        return flow
    }
    
    /// 代理方法，计算都在函数 func layout(_:, _:) 中完成的
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return layout(for: collectionView, on: indexPath.section).itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return layout(for: collectionView, on: section).sectionInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return layout(for: collectionView, on: section).minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return layout(for: collectionView, on: section).minimumInteritemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return layout(for: collectionView).headerReferenceSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        return layout(for: collectionView).footerReferenceSize
    }
}


/// 这个自定义的UICollectionViewFlowLayout子类，能使cell滚动停止时居中显示；
/// accessoryCollectionView 使用了这个布局，在storyboard中设置的。

@IBDesignable class CenterFlowLayout: UICollectionViewFlowLayout {
    
    var horizontalSnapStep: CGFloat {
        return itemSize.width + minimumLineSpacing
    }
    
    var verticalSnapStep: CGFloat {
        return itemSize.height + minimumLineSpacing
    }
    
    var  minHorizontalOffset:CGFloat {
        return -self.collectionView!.contentInset.left
    }
    
    var minVerticalOffset: CGFloat {
        return -self.collectionView!.contentInset.top
    }
    
    var maxHorizontalOffset: CGFloat {
        return minHorizontalOffset + self.collectionView!.contentSize.width - itemSize.width
    }
    
    var maxVerticalOffset: CGFloat {
        return minVerticalOffset + self.collectionView!.contentSize.height - itemSize.height
    }
    
    override func prepare() {
        super.prepare()
        
        self.scrollDirection = .horizontal
    }
    
    func collectionView(_ c: UICollectionView, horizontalTargetOffset proposedOffset: CGPoint, withVelocity velocity: CGPoint) -> CGPoint {
        var proposedOffset = proposedOffset
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalCenter = proposedOffset.x + c.bounds.size.width / 2.0
        let targetRect = CGRect(x: proposedOffset.x, y: 0.0, width: c.bounds.size.width, height: c.bounds.size.height)
        
        guard let layoutAttributes = self.layoutAttributesForElements(in: targetRect) else {
            return proposedOffset
        }
        
        /// Find whose center position is close to screen center
        layoutAttributes.forEach { (layoutAttribute) in
            if layoutAttribute.representedElementCategory == UICollectionElementCategory.cell {
                let distance = layoutAttribute.center.x - horizontalCenter
                if abs(distance) < abs(offsetAdjustment) {
                    offsetAdjustment = distance
                }
            }
        }
        
        var nextOffset = proposedOffset.x + offsetAdjustment
        repeat {
            proposedOffset.x = nextOffset
            let deltaX = proposedOffset.x - c.contentOffset.x
            let velX = velocity.x
            
            if deltaX == 0.0 || velX == 0 || (velX > 0.0 && deltaX > 0.0) || (velX < 0.0 && deltaX < 0.0) {
                break
            }
            if velX > 0.0 {
                nextOffset = nextOffset + horizontalSnapStep
            }
            if velX < 0.0 {
                nextOffset = nextOffset - horizontalSnapStep
            }
        } while nextOffset >= minHorizontalOffset && nextOffset <= maxHorizontalOffset
        
        proposedOffset.y = 0.0
        
        return proposedOffset
    }
    func collectionView(_ c: UICollectionView, verticalTargetOffset proposedOffset: CGPoint, withVelocity velocity: CGPoint) -> CGPoint {
        var proposedOffset = proposedOffset
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalCenter = proposedOffset.y + c.bounds.size.height / 2.0
        let targetRect = CGRect(x: 0, y: proposedOffset.y, width: c.bounds.size.width, height: c.bounds.size.height)
        
        guard let layoutAttributes = self.layoutAttributesForElements(in: targetRect) else {
            return proposedOffset
        }
        
        layoutAttributes.forEach { (layoutAttribute) in
            if layoutAttribute.representedElementCategory == UICollectionElementCategory.cell {
                let distance = layoutAttribute.center.y - horizontalCenter
                if abs(distance) < abs(offsetAdjustment) {
                    offsetAdjustment = distance
                }
            }
        }
        
        var nextOffset = proposedOffset.y + offsetAdjustment
        repeat {
            proposedOffset.y = nextOffset
            let delta = nextOffset - c.contentOffset.y
            let vel = velocity.y
            
            if delta == 0.0 || vel == 0 || (vel > 0.0 && delta > 0.0) || (vel < 0.0 && delta < 0.0) {
                break
            }
            if vel > 0.0 {
                nextOffset = nextOffset + verticalSnapStep
            } else {
                nextOffset = nextOffset - verticalSnapStep
            }
        } while nextOffset >= minVerticalOffset && nextOffset <= maxVerticalOffset
        
        proposedOffset.x = 0.0
        
        return proposedOffset
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let c = collectionView else {
            return proposedContentOffset
        }
        switch scrollDirection {
        case .horizontal: return collectionView(c, horizontalTargetOffset: proposedContentOffset, withVelocity: velocity)
        case .vertical: return collectionView(c, verticalTargetOffset: proposedContentOffset, withVelocity: velocity)
        }
    }
}
