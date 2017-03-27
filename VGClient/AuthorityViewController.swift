//
//  AuthorityViewController.swift
//  VGClient
//
//  Created by jie on 2017/2/20.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

class AuthorityViewController: UIViewController {
    
    @IBOutlet weak var requestButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func didTapRequestButton(_ sender: Any) {
        
    }

    @IBAction func unwindClosing() {
        
        dismiss(animated: true, completion: nil)
    }
}
