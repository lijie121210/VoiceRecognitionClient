//
//  RecordListCell.swift
//  VGClient
//
//  Created by viwii on 2017/3/25.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UIKit


class RecordListCell: UITableViewCell {
    
    static let reuseid = "RecordListCell"
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var translateLabel: UILabel!
    @IBOutlet weak var translationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        /* This can set in func collectionView(_:, cellForItemAt:) -> UICollectionViewCell too. Anywhere that
         collectionView.bounds.width == controller.view.bounds.wdith == UIScreen.main.bounds.width.
         Calculation: w - w1 * 2 - w2 * 2 - w3 * 2 - w4 * 2
         w : width of cell's container
         w1: space between translationLabel's container view and cell's edge
         w2: space between Cell().translationLabel and translationLabel's container view
         w3: content offset of UILabel
         w4: minimumInteritemSpacingForSection
         */
//        translationLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 16 - 80 - 16 - 2.0
        
        /* This cell has many labels, the widest of those labels will hold up the width of the cell, by a priority of 750.
         The widthConstraint requires the cell is wider than it's constant(widthConstraint.constant), by a priority of 1000.
         The result is that these two constraints, which make the cell wider that roles.
         */
//        widthConstraint.constant = UIScreen.main.bounds.width - 40.0
    }
    
}
