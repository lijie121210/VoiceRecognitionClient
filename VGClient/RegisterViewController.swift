//
//  RegisterViewController.swift
//  VGClient
//
//  Created by viwii on 2017/3/26.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit



protocol RegisterDelegate: class {
    
    func register(_ vc: RegisterViewController, didFinishWithUser user: VGUser?)
    
}



class RegisterViewController: UIViewController, UITextFieldDelegate, KeyboardManagerHandler {

    // MARK: - IBOutlet

    @IBOutlet weak var usernameTextField: BorderTextField!
    
    @IBOutlet weak var passwordTextField: BorderTextField!
    
    @IBOutlet weak var confirmPSTextField: BorderTextField!
    
    @IBOutlet weak var deviceIDTextField: BorderTextField!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    // MARK: - properties
    
    public weak var register: RegisterDelegate?
    
    let keyboardManager = KeyboardManager()

    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        adjust(constraint: bottomConstraint, withKeyboard: keyboardManager)

    }
    
    
    
    // MARK: - User Interaction

    @IBAction func didTapCancelControl(_ sender: Any) {
        
        shouldEndEditing()
        
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func didTapDoneButton(_ sender: Any) {
        
        shouldEndEditing()
        
        /// 用户名检查
        guard let username = usernameTextField.text, usernameTextField.isUsernameText else {
            
            warning(message: "账号格式错误!", style: .actionSheet, sourceView: usernameTextField)
            
            return
        }
        
        /// 密码检查
        guard let password = passwordTextField.text, passwordTextField.isPasswordText else {
            
            warning(message: "密码格式错误!", style: .actionSheet, sourceView: passwordTextField)
            
            return
        }
        
        /// 密码确认
        guard passwordTextField.textEqual(to: passwordTextField) else {
            
            warning(message: "密码不能为空, 且应该相同！", style: .actionSheet, sourceView: confirmPSTextField)
            
            return
        }
        
        /// 设备编号
        guard let deviceID = deviceIDTextField.text, deviceIDTextField.isDeviceIDText else {
            
            warning(message: "设备编号格式错误！", style: .actionSheet, sourceView: confirmPSTextField)

            return
        }
        
        UserManager.default.register(username: username, password: password, deviceID: deviceID) { (_) in
            
            let user = VGUser(username: username, password: password, deviceID: deviceID)
            
            self.register?.register(self, didFinishWithUser: user)

            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    
    // MARK: - KeyboardManagerHandler
    
    public var hiddenConstant: CGFloat { return 20.0 }
    
    public var tapGesture: UITapGestureRecognizer?
    
    public func shouldEndEditing() {
        
        view.endEditing(true)
    }
    
    
}
