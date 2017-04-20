//
//  RecordListViewController.swift
//  VGClient
//
//  Created by jie on 2017/2/20.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit
import CoreData

/// Show local records in a list
///
class RecordListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AudioOperatorDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: [AudioRecordItem] = []

    let audioOperator: AudioOperator = AudioOperator()
    
    var orbit: OrbitAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        
        dataSource = CoreDataManager.default.fetch()
        
        audioOperator.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// 显示导航条
        navigationController?.isNavigationBarHidden = false
        navigationItem.leftBarButtonItem?.title = "首页"
        title = "语音指令记录列表"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        audioOperator.releaseResource()
    }
    
    // MARK: -  UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RecordListCell.reuseid, for: indexPath) as! RecordListCell
        let data = dataSource[indexPath.row]
        cell.dateLabel.text = (data.recordDate as Date?)?.utc8()
        cell.durationLabel.text = String(format: "%.1f", data.duration)
        cell.translateLabel.text = "译文"
        if let translation = data.translation {
            cell.translationLabel.text = "\"" + translation + "\""
        } else {
            cell.translationLabel.text = "<-- 无数据 -->"
        }
        return cell
    }
    
    // MARK: -  UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = dataSource[indexPath.row]
        if let path = data.url {
            let url = URL(fileURLWithPath: path)
            do {
                if try audioOperator.startPlaying(url: url) {
                    self.orbit = OrbitAlertController.show(with: "正在播放", on: self)
                    return
                }
            } catch {
            }
        }
        warning(duration: 2, message: "无法播放")
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        let data = dataSource[indexPath.row]
        if CoreDataManager.default.remove(data: data) {
            warning(duration: 2, message: "已删除")
        } else {
            warning(duration: 2, message: "无法删除")
        }
    }
    
    
    // MARK: - AudioOperatorDelegate
    
    func audioOperator(_ audioOperator: AudioOperator, playingTime time: TimeInterval, andPower power: Float) {
        if let orbit = self.orbit {
            orbit.update(prompt: String(format: "%.1f", time))
        }
    }
    
    func audioOperatorDidFinishPlaying(_ audioOperator: AudioOperator) {
        if let orbit = self.orbit {
            orbit.update(prompt: "✅")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { 
                orbit.dismiss(animated: true, completion: nil)
            })
        }
    }
    
}
