//
//  AlternateLayout.swift
//  VGClient
//
//  Created by jie on 2017/3/13.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit



///////// Thanks to

//////// https://www.raywenderlich.com/107439/uicollectionview-custom-layout-tutorial-pinterest

//////// make a little change


/// let collection view calculate height for each item.
///
protocol AlternateLayoutDelegate: class {
    
    func collectionView(_ collectionView: UICollectionView, heightForItem atIndexPath: IndexPath, withWidth: CGFloat) -> CGFloat
}



/// contains `height` property.
///
class AlternateLayoutAttributes: UICollectionViewLayoutAttributes {
    
    // 1. Custom attribute
    var height: CGFloat = 0.0
    
    // 2. Override copyWithZone to conform to NSCopying protocol
    override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! AlternateLayoutAttributes
        copy.height = height
        return copy
    }
    
    // 3. Override isEqual
    override func isEqual(_ object: Any?) -> Bool {
        if let attributtes = object as? AlternateLayoutAttributes {
            if( attributtes.height == height  ) {
                return super.isEqual(object)
            }
        }
        return false
    }
}



/// Alternate Layout
///
class AlternateLayout: UICollectionViewLayout {

    //1. Alternate Layout Delegate
    weak var delegate: AlternateLayoutDelegate?
    
    
    //2. Configurable properties
    
    var numberOfColumns = 2
    
    var cellPadding: CGFloat = 4.0
    
    
    //3. Array to keep a cache of attributes.
    fileprivate var cache: [AlternateLayoutAttributes] = []
    
    
    //4. Content height and size
    fileprivate var contentHeight:CGFloat  = 0.0
    
    fileprivate var contentWidth: CGFloat {
        
        let insets = collectionView!.contentInset
        
        return collectionView!.bounds.width - (insets.left + insets.right)
    }
    
    
    /// override point.
    override class var layoutAttributesClass : AnyClass {
        return AlternateLayoutAttributes.self
    }
    
    
    
    override func prepare() {
        
        // 1. Only calculate once
        guard cache.isEmpty else { return }
        
        
        // 2. Pre-Calculates the X Offset for every column and adds an array to increment the currently max Y Offset for each column
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth )
        }
        
        
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        
        // 3. Iterates through the list of items in the first section
        for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            
            
            // 4. Asks the delegate for the height of the picture and the annotation and calculates the cell frame.
            
            let width = columnWidth - cellPadding*2
            
            let delegateHeight = delegate?.collectionView(collectionView!, heightForItem: indexPath, withWidth:width) ?? 130.0
            
            let height = cellPadding +  delegateHeight + cellPadding
            
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            
            // 5. Creates an UICollectionViewLayoutItem with the frame and add it to the cache
            
            let attributes = AlternateLayoutAttributes(forCellWith: indexPath)
            attributes.height = delegateHeight
            attributes.frame = insetFrame
            cache.append(attributes)
            
            
            // 6. Updates the collection view content height
            
            contentHeight = max(contentHeight, frame.maxY)
            
            yOffset[column] = yOffset[column] + height
            
            if column >= numberOfColumns - 1 {
                column = 0
            } else {
                column = column + 1
            }
        }
    }
    
    
    override var collectionViewContentSize : CGSize {
        
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes  in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        
        return layoutAttributes
    }
    
    
    override func invalidateLayout() {
        
        cache.removeAll()
        
        super.invalidateLayout()
    }
}
