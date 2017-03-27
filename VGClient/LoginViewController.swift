//
//  LogInViewController.swift
//  VGClient
//
//  Created by viwii on 2017/3/25.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController, UITextFieldDelegate, KeyboardManagerHandler, RegisterDelegate {

    // MARK: - IBOutlet
    
    @IBOutlet weak var fingerprintButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var usernameTextField: BorderTextField!
    
    @IBOutlet weak var passwordTextField: BorderTextField!
    
    /// 一个遮罩图层；用于遮挡真实内容；
    @IBOutlet weak var coverView: UIView!
    
    
    // MARK: - Properties
    
    let keyboardManager = KeyboardManager()
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        adjust(constraint: bottomConstraint, withKeyboard: keyboardManager)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// 依据登录情况，初始化视图状态
        
        if let user = UserManager.default.currentUser {
            
            usernameTextField.text = user.username
            
            passwordTextField.text = user.password
            
            /// 存在账户信息，只需要指纹识别
            fingerprintButton.isEnabled = true
            
            coverView.isHidden = false

        } else {
            
            // 未登录
            fingerprintButton.isEnabled = false
            
            coverView.isHidden = true
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /// 触发指纹识别
        if let _ = UserManager.default.currentUser {
            
            touchIDAuthenticate()
        }
        
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "RegisterViewController", let vc = segue.destination as? RegisterViewController {
            
            vc.register = self
        }
    }

    
    
    // MARK: - Views 
    
    
    
    // MARK: - User Interaction
    
    /// 再次尝试使用指纹识别
    @IBAction func didTapFingerprintButton(_ sender: Any) {
        
        touchIDAuthenticate()
        
    }
    
    @IBAction func didTapLoginButton(_ sender: Any) {
        
        /// end editing
        shouldEndEditing()
        
        /// 用户名检查
        guard usernameTextField.isUsernameText, let username = usernameTextField.text else {
            
            warning(message: "账号格式错误!", style: .actionSheet, sourceView: usernameTextField)
                
            return
        }
        
        /// 密码检查
        guard passwordTextField.isPasswordText, let password = passwordTextField.text else {
            
            warning(message: "密码格式错误!", style: .actionSheet, sourceView: passwordTextField)

            return
        }
        
        /// 登录
        UserManager.default.login(username: username, password: password) { (result) in
            
            DispatchQueue.main.async {
                if result {
                    
                    self.authenticateSuccessed()
                }else {
                    
                    self.warning(message: "登录失败")
                }
            }
        }
        
    }
    
    
    
    // MARK: - UITextField delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        shouldEndEditing()
        
        return false
    }
    
    
    
    // MARK: - KeyboardManagerHandler
    
    public var hiddenConstant: CGFloat {
        return 100.0
    }
    
    public var tapGesture: UITapGestureRecognizer?

    public func shouldEndEditing() {
        
        view.endEditing(true)
    }
    
    
    
    // MARK: - RegisterDelegate
    
    func register(_ vc: RegisterViewController, didFinishWithUser user: VGUser?) {
        
        if let user = user {
            
            usernameTextField.text = user.username

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { 
                self.warning(message: "注册成功, 请登录", style: .actionSheet, sourceView: self.loginButton)
            })

        } else {
            
            warning(message: "注册失败")
        }
    }
    
    
    // MARK: - Helper
    
    /// 指纹识别验证身份
    private func touchIDAuthenticate() {
        
        UserManager.default.touchIDAuthenticate(complete: { (result, error) in
            
            DispatchQueue.main.async {
                if result {
                    
                    self.authenticateSuccessed()
                } else {
                    
                    /// 去除遮罩
                    self.coverView.isHidden = true
                    
                    /// 可以再次触发指纹识别
                    self.fingerprintButton.isEnabled = true

                    self.warning(message: "请输入登录信息，进行身份验证")
                }
            }
        })
        
    }
    
    /// 认证成功，跳转页面
    private func authenticateSuccessed() {
        
        guard let app = UIApplication.shared.delegate as? SwitchRootController else {
            return
        }
        
        app.shouldSwitchRootCOntrollerToMaster()
    }
}
