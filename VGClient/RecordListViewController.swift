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
    @IBOutlet weak var actionsStackView: UIStackView!
    @IBOutlet weak var deletionButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    private var isTargeted: Bool = false
    
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
    
    func addTarget(target: Any?, deleteAction: Selector, playAction: Selector, sendAction: Selector, for event: UIControlEvents) {
        guard isTargeted == false else {
            return
        }
        isTargeted = true
        
        deletionButton.addTarget(target, action: deleteAction, for: event)
        playButton.addTarget(target, action: playAction, for: event)
        sendButton.addTarget(target, action: sendAction, for: event)
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

    /// Reuse identifiers wrapper
    struct ID {
        static let cell = "\(RecordListCell.self)"
        static let header = "\(RecordListHeader.self)"
        static let footer = "\(RecordListFooter.self)"
    }
    
    @IBOutlet weak var recordCollectionView: UICollectionView!
    
    /// self.parent is the containing view controller, and will be set a value after didMove(_:) method called.
    fileprivate var masterParent: MasterViewController? {
        return parent as? MasterViewController
    }
    
    fileprivate var flowLayout: UICollectionViewFlowLayout {
        return recordCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    fileprivate var dataSource: [AudioData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let w = recordCollectionView.bounds.width * 0.5
        let h: CGFloat = recordCollectionView.bounds.height * 0.5
        
        flowLayout.estimatedItemSize = CGSize(width: w, height: h)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    /// Api for Master view controller
    
    /// Reload collection view with new data source. This method can be called to set the data source.
    func reloadDataSource(data: [AudioData]) {
        
        dataSource.append(contentsOf: data)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { 
            self.recordCollectionView.reloadData()
        }
    }
    
    /// - param head : Indicates where the data source should insert new data into the front.
    func insert(data: AudioData, at head: Bool = true) {
        /// this is the insertion position if head == false.
        var position = dataSource.count
        
        if head {
            dataSource.insert(data, at: 0)
            
            /// change to the front end
            position = 0
        } else {
            dataSource.append(data)
        }
        
        /// update record list view
        recordCollectionView.insertItems(at: [IndexPath(item: position, section: 0)])
    }
    
    
}

extension RecordListViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    /** Those actions need to call methods of parent view controller, and get result through blocks.
     
     */
    fileprivate struct ActionSelectors {
        static var deletion: Selector {
            return #selector(RecordListViewController.deleteRecord(sender:with:))
        }
        static var playing: Selector {
            return #selector(RecordListViewController.playRecord(sender:with:))
        }
        static var sending: Selector {
            return #selector(RecordListViewController.sendRecord(sender:with:))
        }
    }
    
    fileprivate func indexPath(of event: UIEvent?) -> IndexPath? {
        guard
            let list = recordCollectionView,
            let touch = event?.allTouches?.first,
            let index = list.indexPathForItem(at: touch.location(in: list)) else {
                return nil
        }
        return index
    }
    
    func deleteRecord(sender: Any, with event: UIEvent?) {
        guard let index = indexPath(of: event) else {
            return
        }
        dataSource.remove(at: index.item)
        
        recordCollectionView.deleteItems(at: [index])
        
        masterParent?.deletingItem(at: index, with: dataSource[index.item])
    }
    
    func playRecord(sender: Any, with event: UIEvent?) {
        guard let index = indexPath(of: event) else {
            return
        }
        
        masterParent?.playItem(at: index, with: dataSource[index.item], progression: { (progress) in
            
            print(self, #function, progress)
            
        }, completion: { (finish) in
            
            print(self, #function, finish)
            
        })
    }
    
    func sendRecord(sender: Any, with event: UIEvent?) {
        guard let index = indexPath(of: event) else {
            return
        }
        
        masterParent?.sendItem(at: index, with: dataSource[index.item], completion: { (finish) in
            
            print(self, #function, finish)

        })
    }
    
}

extension RecordListViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = dataSource[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ID.cell, for: indexPath) as! RecordListCell
        
        cell.dateLabel.text = data.recordDate.recordDescription
        cell.durationLabel.text = data.duration.dateDescription()
        cell.translateLabel.text = "识别结果"

        /// Since the translation of data maybe nil, so we need to adjust translation label's text color.
        if let translation = data.translation {
            cell.translationLabel.textColor = .black
            cell.translationLabel.text = translation
        } else {
            cell.translationLabel.textColor = .lightGray
            cell.translationLabel.text = "无识别结果"
        }
        
        /// shrink the label to fit it's content
        cell.translationLabel.sizeToFit()
        
        /// bind actions to self
        cell.addTarget(target: self,
                       deleteAction: ActionSelectors.deletion,
                       playAction: ActionSelectors.playing,
                       sendAction: ActionSelectors.sending,
                       for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        /// Section Header
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ID.header, for: indexPath) as! RecordListHeader
            header.titleLabel.text = "已录制"
            return header
        }
        /// Section Footer
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: ID.footer, for: indexPath) as! RecordListFooter
        footer.detailLabel.text = dataSource.isEmpty ? "no record" : "no more"
        return footer
    }
}

