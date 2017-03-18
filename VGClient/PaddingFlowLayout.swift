//
//  PaddingFlowLayout.swift
//  VGClient
//
//  Created by viwii on 2017/3/18.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit




/// Thanks to
///
/// http://stackoverflow.com/questions/13492037/targetcontentoffsetforproposedcontentoffsetwithscrollingvelocity-without-subcla
///
/// Scroll to the left padding positon
///
class PaddingFlowLayout: UICollectionViewFlowLayout {
    
    var horizontalPadding: CGFloat = 20.0
    
    var verticalPadding: CGFloat = 20.0
    
    func horizontalAdjustment(_ viewSize: CGSize, forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let targetRect = CGRect(x: proposedContentOffset.x,
                                y: 0,
                                width: viewSize.width,
                                height: viewSize.height)
        
        guard let visibleLayoutAttrs = super.layoutAttributesForElements(in: targetRect) else {
            return proposedContentOffset
        }
        
        let horizontalOffset = proposedContentOffset.x + horizontalPadding
        visibleLayoutAttrs.forEach { (attr) in
            let distance = attr.frame.origin.x - horizontalOffset
            if abs(distance) < abs(offsetAdjustment) {
                offsetAdjustment = distance
            }
        }
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
    
    func verticalAdjustment(_ viewSize: CGSize, forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let targetRect = CGRect(x: 0,
                                y: proposedContentOffset.y,
                                width: viewSize.width,
                                height: viewSize.height)
        
        guard let visibleLayoutAttrs = super.layoutAttributesForElements(in: targetRect) else {
            return proposedContentOffset
        }
        
        let horizontalOffset = proposedContentOffset.y + verticalPadding
        
        visibleLayoutAttrs.forEach { (attr) in
            let distance = attr.frame.origin.y - horizontalOffset
            if abs(distance) < abs(offsetAdjustment) {
                offsetAdjustment = distance
            }
        }
        
        return CGPoint(x: proposedContentOffset.x, y: proposedContentOffset.y + offsetAdjustment)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.scrollDirection = .horizontal
        
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let c = collectionView else {
            return proposedContentOffset
        }
        switch scrollDirection {
        case .horizontal: return horizontalAdjustment(c.bounds.size, forProposedContentOffset: proposedContentOffset)
        case .vertical: return verticalAdjustment(c.bounds.size, forProposedContentOffset: proposedContentOffset)
        }
        
    }
    
}
