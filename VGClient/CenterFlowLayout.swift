//
//  CenterFlowLayout.swift
//  VGClient
//
//  Created by jie on 2017/3/13.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

/// 这个自定义的UICollectionViewFlowLayout子类，能使cell滚动停止时居中显示；
/// accessoryCollectionView 使用了这个布局，在storyboard中设置的。

class CenterFlowLayout: UICollectionViewFlowLayout {
    
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
    
    var isHorizontal: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.scrollDirection = isHorizontal ? .horizontal : .vertical
        
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
