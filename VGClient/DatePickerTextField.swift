//
//  DatePickerTextField.swift
//  VGClient
//
//  Created by viwii on 2017/4/5.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

/**
 * 用于选择监测数据类型的输入框
 */
@IBDesignable
class DatePickerTextField: UITextField {
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            if let imgView = leftView as? UIImageView {
                imgView.image = leftImage
            } else {
                let imgView = UIImageView(frame: CGRect(x: 1, y: 1, width: 30, height: frame.height - 2))
                imgView.image = leftImage
                imgView.contentMode = .center
                leftView = imgView
                leftViewMode = .always
            }
        }
    }
    
    // MARK: - Property
    
    weak var pickerDelegate: PickerTextFieldDelegate?
    
    var result: String? {
        guard let picker = inputView as? UIDatePicker else {
            return nil
        }
        let components = picker.calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: picker.date)
        
        guard
            let year = components.year,
            let month = components.month,
            let day = components.day,
            let hour = components.hour,
            let minute = components.minute,
            let second = components.second else {
                return nil
        }
        return "\(year)-\(month)-\(day) \(hour):\(minute):\(second)"
    }
    
    
    // MARK: - Initilization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initilization()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initilization()
    }
    
    private func initilization() {
        let picker = UIDatePicker(frame: CGRect.zero)
        picker.datePickerMode = .dateAndTime
        picker.addTarget(self, action: #selector(DatePickerTextField.changed(_:)), for: .valueChanged)
        
        let hook = HookControl(frame: CGRect(x: 0, y: 0, width: 0, height: 40))
        hook.fillColor = .clear
        hook.strokeColor = .white
        hook.addTarget(self, action: #selector(DatePickerTextField.done(_:)), for: .touchUpInside)
        
        inputView = picker
        inputAccessoryView = hook
    }
    
    
    // MARK: - UserInteraction
    
    @objc private func changed(_ sender: Any) {
        guard let result = self.result else {
            return
        }

        text = result

        pickerDelegate?.textField(self, didSelect: result)
    }
    
    @objc private func done(_ sender: Any) {
        resignFirstResponder()
        
        text = result

        pickerDelegate?.textField(self, didResignFirstResponder: result)
    }
    
}
