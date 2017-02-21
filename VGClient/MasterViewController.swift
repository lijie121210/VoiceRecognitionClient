//
//  MasterViewController.swift
//  VGClient
//
//  Created by jie on 2017/2/20.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {

    /// It needs to be responsible for the full operation of the data, including access, playing and sending
    fileprivate var dataManager: AudioDataManager = AudioDataManager()
    
    /** There is no need to increase the reference to children controllers, check them at any time.
     s: the master view controller; c: a view controller of a container view which will be added to s.
     When the master loading container views from the storyboard, the order is :
     --> s.prepare(for:sender:)
     --> c.viewDidLoad()
     --> s.addChildViewController
     --> c.didMove(toParentViewController:)
     after the s loaded all it's children view controllers
     --> s.viewDidLoad
     --> s.viewWillAppear
     --> c.viewWillAppear
     --> s.viewDidAppear
     --> c.viewDidAppear
     */
    fileprivate var recordList: RecordListViewController? {
        return childViewControllers.filter { $0 is RecordListViewController }.first as? RecordListViewController
    }
    
    fileprivate var dashboard: DashboardViewController? {
        return childViewControllers.filter { $0 is DashboardViewController }.first as? DashboardViewController
    }
    
    fileprivate var authority: AuthorityViewController? {
        return childViewControllers.filter { $0 is AuthorityViewController }.first as? AuthorityViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataManager.loadLocalData()
        
        recordList?.reloadDataSource(data: dataManager.datas)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    /// Callback method from children view controllers
    
    func deletingItem(at index: IndexPath, with data: AudioData) {
        
        dataManager.remove(at: index.item)
    }
    
    func playItem(at index: IndexPath, with data: AudioData, progression: ( (Float) -> () )? = nil, completion: ( (Bool) -> () )? = nil) {
        
    }
    
    func sendItem(at index: IndexPath, with data: AudioData, completion: ( (Bool) -> () )? = nil) {
        
    }
    
}

