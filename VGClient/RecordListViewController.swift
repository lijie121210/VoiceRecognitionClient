//
//  RecordListViewController.swift
//  VGClient
//
//  Created by jie on 2017/2/20.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit


class RecordListCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: RectCornerView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var translateLabel: UILabel!
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!

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
}

class RecordListHeader: UICollectionReusableView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
}

class RecordListFooter: UICollectionReusableView {
    
    @IBOutlet weak var detailLabel: UILabel!
    
}


/// Show local records in a list
class RecordListViewController: UIViewController {

    struct ID {
        
        /// Reuse identifiers
        static let cell = "RecordListCell"
        static let header = "RecordListHeader"
        static let footer = "RecordListFooter"
        
        /// Kinds
        static let headerKind = UICollectionElementKindSectionHeader
        static let footerKind = UICollectionElementKindSectionFooter
    }
    
    @IBOutlet weak var recordCollectionView: UICollectionView!
    
    fileprivate var flowLayout: UICollectionViewFlowLayout {
        return recordCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    fileprivate var dataManager: AudioDataManager = AudioDataManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        let w = recordCollectionView.bounds.width * 0.5
        let h: CGFloat = recordCollectionView.bounds.height * 0.5
        
        flowLayout.estimatedItemSize = CGSize(width: w, height: h)
        
        dataManager.loadLocalData()
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        print(self, #function, view.bounds.width, recordCollectionView.bounds.width)

        if parent == nil {
            
            /// release source
            
        } else {
            
            /// move on new parent view controller

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension RecordListViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataManager.datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ID.cell, for: indexPath) as! RecordListCell
        cell.dateLabel.text = Date().recordDescription
        cell.durationLabel.text = "00:01:03"
        cell.translateLabel.text = "译文"

        let translation = "This recipe demonstrates how to create table view cells, where the cell height is determined by the cell's content using Auto Layout. In this example, each cell's height is determined by the text view's intrinsic content size--the more text in the text view, the taller the cell. \nFor Auto Layout to calculate the text view's intrinsic content size, you must disable scrolling and then constrain the view's width (in this case, by pinning it to the superview's leading and trailing margins). Auto Layout then calculates an intrinsic height for the given width. "
        
        var str = "For Auto Layout to calculate the text view's intrinsic content size, you must disable scrolling and then constrain the view's width (in this case, by pinning it to the superview's leading and trailing margins). Auto Layout then calculates an intrinsic height for the given width"
        switch indexPath.item % 3 {
        case 0:
            str = translation + str
        case 1:
            str = "indexPath: \(indexPath.section) - \(indexPath.item)"
        default: break
        }
        cell.translationLabel.text = str
        cell.translationLabel.sizeToFit()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: ID.headerKind, withReuseIdentifier: ID.headerKind, for: indexPath) as! RecordListHeader
            
            header.titleLabel.text = "已录制"
            
            return header
        }
        
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: ID.footerKind, withReuseIdentifier: ID.footer, for: indexPath) as! RecordListFooter
        
        footer.detailLabel.text = "no more ..."
        
        return footer
    }
}

extension RecordListViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    
}
