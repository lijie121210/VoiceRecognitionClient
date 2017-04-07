//
//  LineChartView.swift
//  VGClient
//
//  Created by viwii on 2017/4/6.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

class LineChartView: UIView {

    
    var chart: LineChart?
    
    
    func reloadView() {
        if let c = chart {
            c.removeFromSuperview()
            chart = nil
        }
        chart = LineChart()
        chart?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chart!)
        layout(lineChart: chart!)
    }
    
    
    // MARK: - Helper
    
    private func layout(lineChart c: LineChart) {
        let views = ["v":c]
        let options: NSLayoutFormatOptions = [.alignAllCenterX,.alignAllCenterY]
        addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[v]-(0)-|",
                                           options: options,
                                           metrics: nil,
                                           views: views) +
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[v]-(0)-|",
                                           options: options,
                                           metrics: nil,
                                           views: views)
        )
    }

}
