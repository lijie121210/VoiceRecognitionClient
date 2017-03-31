//
//  RecordListViewController.swift
//  VGClient
//
//  Created by jie on 2017/2/20.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

/// Add MasterViewController as parent
/// self.parent is the containing view controller, and will be set a value after didMove(_:) method called.
extension RecordListViewController {
    var masterParent: MasterViewController? {
        return parent as? MasterViewController
    }
}

/// Show local records in a list
class RecordListViewController: UIViewController {

    @IBOutlet weak var recordCollectionView: UICollectionView!
    
    fileprivate var flowLayout: UICollectionViewFlowLayout {
        return recordCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    fileprivate var dataSource: [AudioData] = []

    fileprivate var playingIndex: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let w = recordCollectionView.bounds.width * 0.5
        let h: CGFloat = recordCollectionView.bounds.height * 0.5
        
        flowLayout.estimatedItemSize = CGSize(width: w, height: h)
    }

    /// Api for Master view controller
    
    var isActionEnabled: Bool = true {
        didSet {
            self.recordCollectionView.isUserInteractionEnabled = isActionEnabled
        }
    }
    
    var currentIndexSet: [IndexPath] {
        var indexs = [IndexPath]()
        
        for i in 0 ..< dataSource.count {
            indexs.append(IndexPath(item: i, section: 0))
        }
        return indexs
    }
    
    /// Reload collection view with new data source. This method can be called to set the data source.
    func reloadDataSource(data: [AudioData]) {
        
        recordCollectionView.performBatchUpdates({
            
            let indexs = self.currentIndexSet
            
            self.dataSource.removeAll()
            
            self.recordCollectionView.deleteItems(at: indexs)
            
            data.forEach {
                self.dataSource.insert($0, at: 0)
            }
            
            self.recordCollectionView.insertItems(at: self.currentIndexSet)
            
            self.recordCollectionView.reloadSections([0])

        }, completion: nil)
    }
    
    /// - param head : Indicates where the data source should insert new data into the front.
    func insert(data: AudioData, at head: Bool = true) {
        /// this is the insertion position if head == false.
        var position: Int
        
        if head {
            dataSource.insert(data, at: 0)
            position = 0
        } else {
            dataSource.append(data)
            position = dataSource.count
        }
        
        /// update record list view
        recordCollectionView.performBatchUpdates({
            
            self.recordCollectionView.insertItems(at: [IndexPath(item: position, section: 0)])
        }, completion: nil)
    }
    
    /// Maybe successful, or maybe failed
    func playDidComplete() {
        
        guard
            let index = playingIndex,
            let cell = recordCollectionView.cellForItem(at: index) as? RecordListCell
            else {
                print(self, #function, "caused by scrolling")
                return
        }
        
        recordCollectionView.isScrollEnabled = true
        
        playingIndex = nil
        
        cell.update(playProgress: 0.01)

        cell.isProgressViewVisible = false
        
        cell.update(playImage: .play)
    }
    
    func update(playState time: TimeInterval) {
        
        guard
            let index = playingIndex,
            let cell = recordCollectionView.cellForItem(at: index) as? RecordListCell
            else {
                return print(self, #function, "cased by scrolling")
        }
        let data = dataSource[index.item]
        let duration = data.duration
        let progress = time / duration
        print(self, #function, time, duration, progress)
        cell.update(playProgress: progress)
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
    
    @objc fileprivate func deleteRecord(sender: Any, with event: UIEvent?) {
        
        guard let master = masterParent, let index = indexPath(of: event) else {
            return
        }
        
        master.deletingItem(at: index, with: dataSource[index.item]) { finish in
            if !finish {
                return print("fail to remove <\(index)>")
            }
            
            self.dataSource.remove(at: index.item)
            
            self.recordCollectionView.deleteItems(at: [index])
        }
    }
    
    @objc fileprivate func playRecord(sender: Any, with event: UIEvent?) {
        
        guard
            let master = masterParent,
            let index = indexPath(of: event),
            let cell = recordCollectionView.cellForItem(at: index) as? RecordListCell
            else {
                return print(self, #function, "play can not start")
        }
        
        playDidComplete()

        recordCollectionView.isScrollEnabled = false

        if let playingIndex = playingIndex, playingIndex == index {
            
            master.stopPlayItem(at: index, with: dataSource[index.item])

        } else {

            let start = master.playItem(at: index, with: dataSource[index.item])
            
            guard start else { return }
            
            /// set this value should after asked master!
            playingIndex = index
            
            cell.isProgressViewVisible = true
            cell.update(playImage: .stop)
            cell.update(playProgress: 0.01)
        }
        
        
    }
    
    @objc fileprivate func sendRecord(sender: Any, with event: UIEvent?) {
        
        guard let master = masterParent, let index = indexPath(of: event) else {
            return
        }
        
        master.sendItem(at: index, with: dataSource[index.item])
    }
    
}

extension RecordListViewController: UICollectionViewDataSource {
    
    /// Reuse identifiers wrapper
    struct ID {
        static let cell = "\(RecordListCell.self)"
        static let header = "\(RecordListHeader.self)"
        static let footer = "\(RecordListFooter.self)"
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = dataSource[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ID.cell, for: indexPath) as! RecordListCell

        cell.dateLabel.text = data.recordDate.recordDescription
        cell.durationLabel.text = data.duration.timeDescription
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
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: ID.footer, for: indexPath)
        return footer
    }
}

