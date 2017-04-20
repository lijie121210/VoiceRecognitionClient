//
//  AuthorityViewController.swift
//  VGClient
//
//  Created by jie on 2017/2/20.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit
import Photos


class AuthorityViewController: UIViewController {
    
    // MARK: - Type
    
    enum RequestProgress: Int {
        case notification
        case microphone
        case speech
    }
    
    
    // MARK: - Outlet
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var requestButtonContainer: RectCornerView!
    @IBOutlet weak var requestButton: UIButton!
    
    
    // MARK: - Properties
    
    /// 申请的状态进度
    private var progress: RequestProgress = .microphone
    
    /// 申请提示信息，包括申请原因，申请图标。
    private var propertyList: PermissionPropertyList? = PermissionPropertyList()
    
    
    // MARK: - View controller
    
    deinit {
        print(self, #function)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progress = .notification
        
        progressView.progress = 0.0
        
        imageView.image = propertyList?.notificationAssets
        
        textView.text = propertyList?.notificationDescription ?? ""
        
        requestButton.setTitle("授权", for: .normal)
    }
    
    
    // MARK: - User interaction
    
    @IBAction func didTapRequestButton(_ sender: Any) {
        
        switch progress {
        case .notification:
            PermissionRequest.default.requestNotificationAuthorization({ (granted) in
                self.changeToRequestMicrophone()
            })
        case .microphone:
            PermissionRequest.default.requestRecordPermission({ (granted) in
                if #available(iOS 10.0, *) {
                    self.changeToRequestSpeech()
                } else {
                    self.changeToCompletion()
                }
                
            })
            
        case .speech:
            if #available(iOS 10.0, *) {
                PermissionRequest.default.requestSpeechAuthorization({ (status) in
                    self.changeToCompletion()
                })
            }
        }
    }

    @IBAction func unwindClosing(_ sender: Any) {
        
        PermissionDefaultValue.isRequestedPermission = true
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - Helper
    
    private func changeToRequestMicrophone() {
        let closure = {
            self.progress = .microphone
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.progressView.progress = 0.333
                
                self.imageView.alpha = 0
                self.textView.alpha = 0
            })
            
            self.imageView.image = self.propertyList?.microphoneAssets
            self.textView.text = self.propertyList?.microphoneDescription ?? ""
            
            UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseInOut, animations: {
                self.imageView.alpha = 1.0
                self.textView.alpha = 1.0
            }, completion: nil)
        }
        /// execute on main thread
        if Thread.current.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async(execute: closure)
        }
    }
    
    private func changeToRequestSpeech() {
        let closure = {
            self.progress = .speech
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.progressView.progress = 0.667
                
                self.imageView.alpha = 0
                self.textView.alpha = 0
            })
            
            self.imageView.image = self.propertyList?.speechAssets
            self.textView.text = self.propertyList?.speechDescription ?? ""
            
            UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseInOut, animations: { 
                self.imageView.alpha = 1.0
                self.textView.alpha = 1.0
            }, completion: nil)
        }
        /// execute on main thread
        if Thread.current.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async(execute: closure)
        }
    }
    
    private func changeToCompletion() {
        let closure = {
            self.progressView.progress = 1.0

            self.imageView.image = self.propertyList?.checkAssets
            
            self.textView.text = self.propertyList?.checkDescription
            
            UIView.animate(withDuration: 0.2, animations: { 
                self.requestButtonContainer.alpha = 0.0
            })
        }
        /// execute on main thread
        if Thread.current.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async(execute: closure)
        }
    }
}
