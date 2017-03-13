//
//  ListenViewController.swift
//  VGClient
//
//  Created by jie on 2017/3/10.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

/// 只是显示一个正在录音或者没有录音的状态。
///
class ListenViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet var waveViews: [WaveView]!
    
    deinit {
        print(self, #function)
    }
    
    /// 开始监听录音幅度变化
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DataManager.default.addObserver(self,
                                        forKeyPath: #keyPath(DataManager.averagePower),
                                        options: [.new],
                                        context: nil)
        
    }

    /// 更新标题

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if DataManager.default.isRecording {
            
            titleLabel.text = "正在聆听"
        } else {
            
            titleLabel.text = "无法聆听"
        }
    }
    
    /// 移除监听录音幅度变化

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DataManager.default.removeObserver(self,
                                           forKeyPath: #keyPath(DataManager.averagePower),
                                           context: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    /// 关闭
    
    @IBAction func close() {
        
        dismiss(animated: true, completion: nil)
    }
    
    /// 监听事件
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if
            let path = keyPath, path == #keyPath(DataManager.averagePower),
            let power = change?[.newKey] as? Float {
            
            let level = pow(10, power / 50.0)
            let level2 = pow(10, power / 40.0)
            
            waveViews.forEach { $0.level = $0.tag == 2 ? level : level2 }
            
            return
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
}
 
