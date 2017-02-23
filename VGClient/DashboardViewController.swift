//
//  DashboardViewController.swift
//  VGClient
//
//  Created by jie on 2017/2/20.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {

    /// Record constraint, button and container view
    @IBOutlet weak var topConstraintOfRecrod: NSLayoutConstraint!
    @IBOutlet weak var recordContainerView: RectCornerView!
    @IBOutlet weak var recordButton: UIButton!
    
    /// labels and buttons on dashboard
    @IBOutlet weak var consoleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var consoleContainerView: RectCornerView!
    @IBOutlet weak var consoleTitleLabel: UILabel!
    @IBOutlet weak var consoleTimeLabel: UILabel!
    
    /// this stack view contains those three buttons
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    fileprivate var recordingTimeInterval: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetLabels()

        resetLayout()
    }
    
    /// Actions 
    
    fileprivate func changeButtonState(isEnabled: Bool) {
        cancelButton.isEnabled = isEnabled
        finishButton.isEnabled = isEnabled
        sendButton.isEnabled = isEnabled
    }
    fileprivate func disabledAllButtons() {
        
        changeButtonState(isEnabled: false)
    }
    
    fileprivate func enabledAllButtons() {
        
        changeButtonState(isEnabled: true)
    }
    
    @IBAction func didTapRecordButton(_ sender: Any, forEvent event: UIEvent) {
        
        guard let master = masterParent else {
            return
        }
        
        let result = master.shouldStartRecording()
        
        if !result {
            return
        }
        
        resetLabels()
        
        enabledAllButtons()

        animationForStartingRecord()
    }
    
    @IBAction func didTapSendButton(_ sender: Any, forEvent event: UIEvent) {
        
        guard let master = masterParent else {
            return
        }
        
        disabledAllButtons()
        
        update(consoleTitleLabel: .sending)
                
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            master.attemptToSendRecord()

            self.animationForEndingRecord()
        }
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        guard let master = masterParent else {
            return
        }
        
        disabledAllButtons()
        
        update(consoleTitleLabel: .cancel)
        
        update(consoleTimeLabel: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            master.attemptToCancelRecording()

            self.animationForEndingRecord()
        }
        
    }
    
    @IBAction func didTapFinishButton(_ sender: Any) {
        guard let master = masterParent else {
            return
        }
        
        disabledAllButtons()
        
        update(consoleTitleLabel: .finish)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            master.attemptToStopRecording()

            self.animationForEndingRecord()
        }
    }
    
}



/// Labels prompts
extension DashboardViewController {
    
    enum PromptText: String {
        
        case finishImage = "stop"
        
        enum ConsoleTitle: String {
            case recording = "正在录制"
            case cancel = "取消录制"
            case finish = "录制完成"
            case recordfail = "录制失败"
            case audition = "正在试听"
            case disaudition = "无法试听"
            case failaudition = "停止试听"
            case sending = "正在发送"
        }
    }
    
    func resetLabels() {
        
        update(consoleTimeLabel: 0)
        update(consoleTitleLabel: .recording)
        update(finishButton: .finishImage)
    }
    
    func update(finishButton imageName: PromptText) {
        
        finishButton.setImage(UIImage(named: imageName.rawValue)!, for: .normal)
    }
    func update(consoleTitleLabel text: PromptText.ConsoleTitle) {
        
        consoleTitleLabel.text = text.rawValue
    }
    
    func update(consoleTimeLabel time: TimeInterval) {
        
        if recordingTimeInterval == Int(time) {
            return
        }
        
        recordingTimeInterval = Int(time)
        
        consoleTimeLabel.text = time.timeDescription
    }

}



/// Layout
extension DashboardViewController {
    
    struct Constants {
        
        static let show_recordButton: CGFloat = 20.0
        static let hide_recordButton: CGFloat = 140.0
        
        static let show_consoles: CGFloat = 20.0
        static let hide_consoles: CGFloat = 120.0
    }
    
    fileprivate func resetLayout() {
        
        topConstraintOfRecrod.constant = Constants.show_recordButton
        consoleTopConstraint.constant = Constants.hide_consoles
        view.layoutIfNeeded()
    }
    
    fileprivate func animationForStartingRecord() {
        
        UIView.animate(withDuration: 0.2) {
            self.recordContainerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }
        
        UIView.animate(withDuration: 0.25, delay: 0.15, usingSpringWithDamping: 0.62, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            
            self.topConstraintOfRecrod.constant = Constants.hide_recordButton
            self.consoleTopConstraint.constant = Constants.show_consoles
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    fileprivate func animationForEndingRecord() {
        
        self.recordContainerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.62, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            
            self.topConstraintOfRecrod.constant = Constants.show_recordButton
            self.consoleTopConstraint.constant = Constants.hide_consoles
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.animate(withDuration: 0.2, delay: 0.08, options: .curveEaseInOut, animations: {
            self.recordContainerView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}
