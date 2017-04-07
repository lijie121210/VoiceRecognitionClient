//
//  AnalysisController.swift
//  VGClient
//
//  Created by viwii on 2017/4/5.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

class AnalysisController: UIViewController {
    
    // MARK: - outlet
    
    @IBOutlet weak var dismissControl: ArrowControl!
    @IBOutlet weak var measurementTypeTF: MeasurementPickerTextField!
    @IBOutlet weak var fromDatePickerTF: DatePickerTextField!
    @IBOutlet weak var toDatePickerTF: DatePickerTextField!
    @IBOutlet weak var analysisControl: HookControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var lineChartView: LineChartView!
    
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        reLayoutContentView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        lineChartView.reloadView()
        guard let chart = lineChartView.chart else {
            return
        }
        chart.x.labels.visible = false
        chart.y.labels.visible = false
        chart.colors = [UIColor.lightGray]
        chart.addLine([0,1,-1,0])
    }

    
    // MARK: - User Interaction

    @IBAction func didTapDismissControl(_ sender: Any) {
        dismissControl.offset = 0
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapAnalysisButton(_ sender: Any) {
        guard
            let typeText = measurementTypeTF.text,
            let type = MeasurementType(textDescription: typeText),
            let fromString = fromDatePickerTF.text,
            let toString = toDatePickerTF.text else {
                warning(duration: 2, message: "请选择分析的条件")
                return
        }
        
        // check date condition
        do {
            let from = try fromString.dateTimeIntervalFrom1970()
            let to = try toString.dateTimeIntervalFrom1970()
            
            guard from <= to else {
                throw DateConvertError.invalidFormat
            }
        } catch {
            warning(duration: 2, message: "开始时间应早于结束时间")
            return
        }
        
        analysis(type: type, fromDate: fromString, toDate: toString)
    }
    
    
    
    // MARK: - UITextField delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    
    // MARK: - Helper
    
    private func reLayoutContentView() {
        let width = view.frame.width
        contentLeadingConstraint.constant = 0
        contentTrailingConstraint.constant = 0
        contentWidthConstraint.constant = width
        view.layoutIfNeeded() 
    }
    
    private func layoutContentView() {
        
    }
    
    private func analysis(type: MeasurementType, fromDate: String, toDate: String) {
        
        OrbitAlertController.show(with: "加载数据", on: self)
        
        contentLabel.alpha = 0.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { 
            
            OrbitAlertController.dismiss()
            
            let data = MeasurementCurveData(type: .airTemperature,
                                            fromDate: "02/03 08:00",
                                            toDate: "02/9 08:00",
                                            columns: [
                                                LineColumn(value: 20, prompt: "1"),
                                                LineColumn(value: 22, prompt: "2"),
                                                LineColumn(value: 22, prompt: "3"),
                                                LineColumn(value: 24, prompt: "4"),
                                                LineColumn(value: 25, prompt: "5"),
                                                LineColumn(value: 24, prompt: "6"),
                                                LineColumn(value: 25, prompt: "7")])
            
            self.drawChart(data: data)
        }
        
    }
    
    /// 绘制新的图形
    private func drawChart(data: MeasurementCurveData) {
        
        let config = LineConfig()
        
        self.lineChartView.reloadView()
        
        let lineChartView = self.lineChartView.chart!
        
        lineChartView.animation.enabled = config.isAnimatable
        lineChartView.area = config.isArea
        lineChartView.x.labels.visible = config.isLabelsVisible
        lineChartView.y.labels.visible = config.isLabelsVisible
        lineChartView.x.grid.count = config.gridCount
        lineChartView.y.grid.count = config.gridCount
        lineChartView.colors = config.color

        lineChartView.x.axis.inset = 30
        lineChartView.y.axis.inset = 30
        
        lineChartView.x.labels.values = data.xlabels
        
        lineChartView.addLine(data.datas)
    }

}
