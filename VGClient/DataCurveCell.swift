//
//  DataCurveCell.swift
//  VGClient
//
//  Created by jie on 2017/3/11.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

class DataCurveCell: UICollectionViewCell {
    
    /// 项目名称
    @IBOutlet weak var titleLabel: UILabel!
    
    /// 单位
    @IBOutlet weak var unitLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    /// 绘图背景；用于清除或添加代表数据曲线的子视图
    @IBOutlet weak var canvasView: LineChart!
    
    @IBOutlet weak var popLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        canvasView.delegate = self
    }
    
    func update(data: MeasurementCurveData) {

        
        self.titleLabel.text = data.title
        self.dateLabel.text = data.duration
        self.unitLabel.text = "单位: " + data.type.unit.rawValue
        
        
        /// 清除掉原来的图
        
        canvasView.clearAll()
        
        
        /// 绘制新的图形
        
        canvasView.animation.enabled = data.config.isAnimatable
        canvasView.area = data.config.isArea
        canvasView.x.labels.visible = data.config.isLabelsVisible
        canvasView.y.labels.visible = data.config.isLabelsVisible
        canvasView.x.grid.count = data.config.gridCount
        canvasView.y.grid.count = data.config.gridCount
        canvasView.x.axis.inset = 30
        canvasView.y.axis.inset = 30
        canvasView.colors = data.config.color
        canvasView.x.labels.values = data.xlabels
        canvasView.addLine(data.datas)
        
    }
    
    
}



/// 点击图表上的点，显示一个提示框，1.0s后自动隐藏

extension DataCurveCell: LineChartDelegate {
    
    func didSelectDataPoint(_ x: CGFloat, yValues: [CGFloat]) {
        
        UIView.animate(withDuration: 0.5) {
            
            self.popLabel.isHidden = false
            self.popLabel.text = "<x: \(x), y: \(yValues.map{ String(describing: $0) }.joined())>"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            UIView.animate(withDuration: 0.5, animations: {
                self.popLabel.isHidden = true
                self.popLabel.text = nil
            })
        }
    }
    
    
}
