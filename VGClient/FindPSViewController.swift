//
//  FindPSViewController.swift
//  VGClient
//
//  Created by viwii on 2017/3/26.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

class FindPSViewController: UIViewController, KeyboardManagerHandler {

    // MARK: - IBOutlet

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var usernameTextField: BorderTextField!
    
    @IBOutlet weak var deviceIDTextField: BorderTextField!
    
    
    
    // MARK: - Properties

    let keyboardManager = KeyboardManager()

    deinit {
        print(self, #function)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        adjust(constraint: bottomConstraint, withKeyboard: keyboardManager)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        keyboardManager.clear()
    }

    
    
    // MARK: - User Interaction

    @IBAction func didTapCancelButton(_ sender: Any) {
        
        shouldEndEditing()

        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func didTapDoneButton(_ sender: Any) {
        
        shouldEndEditing()

        warning(message: "新密码已经发送到绑定的邮箱或手机")
    }
    
    
    
    // MARK: - KeyboardManagerHandler
    
    public var hiddenConstant: CGFloat { return 20.0 }
    
    public var tapGesture: UITapGestureRecognizer?
    
    public func shouldEndEditing() {
        
        view.endEditing(true)
    }
    

}
