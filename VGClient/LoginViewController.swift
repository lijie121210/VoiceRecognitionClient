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
    
    deinit {
        print(self, #function)
    }
    
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
        
        if PermissionDefaultValue.isRequestedPermission {
            /// 显示了其他视图后返回该页面，改变标记。
//            if isShowingViewController {
//                isShowingViewController = false
//                return
//            }
            /// 触发指纹识别
            if let _ = UserManager.default.currentUser {
                touchIDAuthenticate()
            }
        } else {
            /// 显示申请授权的页面
            guard let authority = UIStoryboard(name: "Authority", bundle: nil).instantiateInitialViewController() else {
                return
            }
            show(authority, sender: nil)
        }
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "RegisterViewController", let vc = segue.destination as? RegisterViewController {
            
            vc.registerDelegate = self
        }
    }

    
    
    // MARK: - Views 
    
    
    
    // MARK: - User Interaction
    
    /// 再次尝试使用指纹识别
    @IBAction func didTapFingerprintButton(_ sender: Any) {
        
        touchIDAuthenticate()
        
    }
    
    @IBAction func didTapLoginButton(_ sender: Any) {
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
        /// end editing
        shouldEndEditing()
        
        /// 登录
        login(username: username, password: password)
    }
    
    
    
    // MARK: - UITextField delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
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
    
    func register(_ vc: RegisterViewController, user: VGUser) {
        let alert = OrbitAlertController.show(with: "正在注册", on: vc)
        
        UserManager.default.register(user: user) { (finish) in
            let item = {
                if finish {
                    alert?.update(prompt: "注册完成")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                        
                        alert?.dismiss(animated: true, completion: nil)
                        
                        vc.dismiss(animated: true, completion: {
                            self.login(username: user.username, password: user.password)
                        })
                    })
                } else {
                    alert?.update(prompt: "注册失败")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                        alert?.dismiss(animated: true, completion: nil)
                    })
                }
            }
            DispatchQueue.main.async(execute: item)
        }
    }
    
    
    // MARK: - Helper
    
    /// login
    private func login(username: String, password: String) {
        let alert = OrbitAlertController.show(with: "正在登录", on: self)
        
        UserManager.default.login(username: username, password: password) { (result) in
            let item = {
                if result {
                    alert?.update(prompt: "登录成功")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        alert?.dismiss(animated: true, completion: nil)
                        
                        self.authenticateSuccessed()
                    })
                }else {
                    alert?.update(prompt: "登录失败")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        alert?.dismiss(animated: true, completion: nil)
                    })
                }
            }
            DispatchQueue.main.async(execute: item)
        }
    }
    
    /// 指纹识别验证身份
    private func touchIDAuthenticate() {
        
        let success = {
            self.authenticateSuccessed()
        }
        
        let fail = {
            
            /// 还是不要自动填充密码了
            self.passwordTextField.text = nil
            
            /// 去除遮罩
            self.coverView.isHidden = true
            
            /// 可以再次触发指纹识别
            self.fingerprintButton.isEnabled = true
            
            self.warning(message: "请输入登录信息，进行身份验证")
        }
        
        let complete = { (result: Bool, error: Error?) in
        
            DispatchQueue.main.async(execute: result ? success : fail )
        }
        
        
        UserManager.default.touchIDAuthenticate(complete: complete)
                
    }
    
    /// 认证成功，跳转页面
    private func authenticateSuccessed() {
        
        guard let app = UIApplication.shared.delegate as? SwitchRootController else {
            return
        }
        
        /// clear keyboard observe
        keyboardManager.clear()
        
        /// switch to master
        app.shouldSwitchRootCOntrollerToMaster()
    }
}
