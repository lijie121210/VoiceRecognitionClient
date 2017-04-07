//
//  PickerTextField.swift
//  VGClient
//
//  Created by viwii on 2017/4/5.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit


protocol PickerTextFieldDelegate: class {
    
    func textField(_ textField: UITextField, didSelect result: String)
    
    func textField(_ textField: UITextField, didResignFirstResponder last: String?)
}


/**
 * 用于选择监测数据类型的输入框
 */
@IBDesignable
class MeasurementPickerTextField: UITextField, UIPickerViewDataSource, UIPickerViewDelegate {
    
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
        guard let picker = inputView as? UIPickerView else {
            return nil
        }
        let index = picker.selectedRow(inComponent: 0)
        return pickerData[index]
    }
    
    private let pickerData = MeasurementTypePickerData()
    
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
        let picker = UIPickerView(frame: CGRect.zero)
        picker.delegate = self
        picker.dataSource = self

        let hook = HookControl(frame: CGRect(x: 0, y: 0, width: 0, height: 40))
        hook.fillColor = .clear
        hook.strokeColor = .white
        hook.addTarget(self, action: #selector(MeasurementPickerTextField.done(_:)), for: .touchUpInside)
        
        inputView = picker
        inputAccessoryView = hook
    }
    
    
    // MARK: - UserInteraction
    
    @objc private func done(_ sender: Any) {
        resignFirstResponder()
        
        text = result

        pickerDelegate?.textField(self, didResignFirstResponder: result)
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 34
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.frame.width
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        text = result

        pickerDelegate?.textField(self, didSelect: pickerData[row])
    }
}
