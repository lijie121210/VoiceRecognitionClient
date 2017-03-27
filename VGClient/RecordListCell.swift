//
//  RecordListCell.swift
//  VGClient
//
//  Created by viwii on 2017/3/25.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UIKit



class RecordListHeader: UICollectionReusableView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
}

class RecordListFooter: UICollectionReusableView {
    
}


class RecordListCell: UICollectionViewCell {
    
    enum PlayImage: String, Equatable {
        case play = "play"
        case stop = "stop"
    }
    
    @IBOutlet weak var containerView: RectCornerView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var translateLabel: UILabel!
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var actionsStackView: UIStackView!
    @IBOutlet weak var deletionButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
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
        translationLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 16 - 80 - 16 - 2.0
        
        /* This cell has many labels, the widest of those labels will hold up the width of the cell, by a priority of 750.
         The widthConstraint requires the cell is wider than it's constant(widthConstraint.constant), by a priority of 1000.
         The result is that these two constraints, which make the cell wider that roles.
         */
        widthConstraint.constant = UIScreen.main.bounds.width - 40.0
    }
    
    private var isTargeted: Bool = false
    
    func addTarget(target: Any?, deleteAction: Selector, playAction: Selector, sendAction: Selector, for event: UIControlEvents) {
        guard isTargeted == false else {
            return
        }
        isTargeted = true
        
        deletionButton.addTarget(target, action: deleteAction, for: event)
        playButton.addTarget(target, action: playAction, for: event)
        sendButton.addTarget(target, action: sendAction, for: event)
    }
    
    var isProgressViewVisible: Bool = false {
        didSet {
            progressView.isHidden = !isProgressViewVisible
        }
    }
    
    func update(playImage named: PlayImage) {
        
        let image = UIImage(named: named.rawValue)
        
        playButton.setImage(image, for: .normal)
    }
    
    func update(playProgress time: TimeInterval) {
        
        progressView.progress = Float(time)
    }
}
