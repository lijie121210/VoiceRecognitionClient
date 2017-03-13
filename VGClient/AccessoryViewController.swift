//
//  AccessoryViewController.swift
//  VGClient
//
//  Created by jie on 2017/3/13.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit


protocol AccessoryOperationDelegate: class {
    
    func accessoryViewController(_ controller: AccessoryViewController, attemptToDelete data: AccessoryData, at indexPath: IndexPath?)
    
    func accessoryViewController(_ controller: AccessoryViewController, attemptToEdit data: AccessoryData, at indexPath: IndexPath?)
    
    func accessoryViewController(_ controller: AccessoryViewController, attemptToAdd data: AccessoryData)

}


class AccessoryViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var container: RectCornerView!
    
    /// 显示附件的名称
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    /// 选择出附件名称：x号xxx附件
    @IBOutlet weak var picker: UIPickerView!
    
    /// 完成
    @IBOutlet weak var doneButton: UIButton!
    
    /// 删除该附件
    @IBOutlet weak var deleteButton: UIButton!
    
    
    @IBAction func didTapOnView(_ sender: Any) {
        
        guard
            let c = self.container,
            let tap = sender as? UITapGestureRecognizer,
            tap.location(in: c).y < 0.0
            else { return }
        
        dismiss(animated: true, completion: nil)
    }
    
    /// 动作
    
    @IBAction func didTapDoneButton(_ sender: Any) {
        
        /// 肯定是要消失界面了
        
        defer {
            dismiss(animated: true, completion: nil)
        }
        
        let numb = pickerData.title.leftTitles[picker.selectedRow(inComponent: 0)]
        let type = pickerData.title.rightTitles[picker.selectedRow(inComponent: 1)]
        let title = numb + type
        
        
        /// 编辑这个设备
        
        if let ca = currentAccessory {
            
            let data = AccessoryData(type: ca.type, state: ca.state, name: title)
            
            delegate?.accessoryViewController(self, attemptToEdit: data, at: currentIndexPath)
            
            return
        }
        
        
        /// 增加一个设备
        
        guard let t = AccessoryType(rawValue: picker.selectedRow(inComponent: 1)) else {
            return print(self, #function, "fail to create accessory type")
        }
        
        let data = AccessoryData(type: t, state: .closed, name: title)
        
        delegate?.accessoryViewController(self, attemptToAdd: data)
        
        
    }
    
    @IBAction func didTapDeleteButton(_ sender: Any) {
        
        /// 肯定是要消失界面了

        defer {
            dismiss(animated: true, completion: nil)
        }
        
        
        /// 删除一个存在的设备
        
        if let data = currentAccessory {
            
            delegate?.accessoryViewController(self, attemptToDelete: data, at: currentIndexPath)
            
            return
        }
        
        /// do nothing
    }
    
    
    
    ///
    
    
    let pickerData = AccessoryPicker()
    
    var currentAccessory: AccessoryData? = nil
    var currentIndexPath: IndexPath? = nil
    
    weak var delegate: AccessoryOperationDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// 编辑已存在的设备, 需要显示默认值
        
        if let accessory = currentAccessory {
            
            let name = accessory.name
            
            var type = ""
            if let range = name.range(of: "号") {
                numberLabel.text = name.substring(to: range.lowerBound) + "号"
                type = name.substring(from: range.upperBound)
            } else {
                type = name
            }
            
            titleLabel.text = type
            
            selectType()
        }
        
        
    }
    
    
    /// 选中正在编辑的类型
    
    func selectType() {
        guard let accessory = currentAccessory, let row = pickerData.title.rightTitles.index(of: accessory.type.name) else {
            return
        }
        
        picker.selectRow(row, inComponent: 1, animated: true)
    }
    
    
    
    
    /// UIPickerViewDataSource

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
            return pickerData.title.leftTitles.count
        } else {
            return pickerData.title.rightTitles.count

        }
    }
    
    
    
    
    /// UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
       
        if component == 0 {
            return 60.0
        }
        
        return pickerView.frame.width - 60.0
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        return 44.0
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0 {
            
            return pickerData.title.leftTitles[row]
        } else {
            
            return pickerData.title.rightTitles[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0 {
            
            numberLabel.text = pickerData.title.leftTitles[row]
            
            return
        }
        
        /// 不能修改类型
        
        if let _ = currentAccessory, component == 1 {
            
            selectType()
            
            return
        }
        
        ///
        
        titleLabel.text = pickerData.title.rightTitles[row]

    }
    
}
