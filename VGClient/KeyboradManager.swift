//
//  KeyboradManager.swift
//  VGClient
//
//  Created by viwii on 2017/3/26.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit
import Foundation


/// 共享点击隐藏键盘的点击手势的创建工作
///
@objc public protocol Tappable: class {
    
    var tapGesture: UITapGestureRecognizer? {get set}
    
    func shouldEndEditing()
}

extension Tappable where Self: UIViewController {
    
    func addTapGesture() {
        
        /// remove if existed
        
        removeTapGesture()
        
        /// create new instance
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(Self.shouldEndEditing))
        
        tapGesture = tap
        
        view.addGestureRecognizer(tap)
    }
    
    func removeTapGesture() {
        
        if let tap = tapGesture {
            
            view.removeGestureRecognizer(tap)
            
            tapGesture?.delegate = nil
            
            tapGesture = nil
        }
        
    }
    
}



public protocol ConstraintAdjustable: class {
    
    var hiddenConstant: CGFloat { get }
    
    func adjust(constraint: NSLayoutConstraint, withKeyboard keyboard: KeyboardManager)
}

extension ConstraintAdjustable where Self: UIViewController, Self: Tappable {
    
    func adjust(constraint: NSLayoutConstraint, withKeyboard keyboard: KeyboardManager) {
    
        keyboard.showClosure = { [weak self] frame in
            
            guard let sself = self else { return }
            
            /// add tap gesture
            
            sself.addTapGesture()
            
            /// adjust view bottom contraint
            
            guard frame.height > constraint.constant else { return }
            
            constraint.constant = frame.height + 20
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
                
                sself.view.layoutIfNeeded()
                
            }, completion: nil)
        }
        
        keyboard.hideClosure = { [weak self] in
            
            guard let sself = self else { return }
            
            /// remove tap gesture
            
            sself.removeTapGesture()
            
            /// adjust view bottom contraint
            
            constraint.constant = sself.hiddenConstant
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
                
                sself.view.layoutIfNeeded()
                
            }, completion: nil)
        }
        
    }
}


/// 这两个接口完成了根据键盘调整视图的大部分工作
///
public typealias KeyboardManagerHandler = Tappable & ConstraintAdjustable



public final class KeyboardManager: NSObject {
    
    /// 添加事件回调
    
    public var showClosure: ( (CGRect) -> Void )?
    
    public var hideClosure: ( () -> Void )?
    
    
    public override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardManager.keyboardWillDisappear(sender:)), name: .UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardManager.keyboardWillAppear(sender:)), name: .UIKeyboardWillShow, object: nil)
    }
    
    @objc private func keyboardWillAppear(sender: Any) {
        
        guard
            let notification = sender as? Notification,
            let userinfo = notification.userInfo,
            let frameValue = userinfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
                return
        }
        
        let frame = frameValue.cgRectValue

        if let c = showClosure {
            c(frame)
        }
    }
    
    @objc private func keyboardWillDisappear(sender: Any) {
        
        if let c = hideClosure {
            c()
        }
    }
}


