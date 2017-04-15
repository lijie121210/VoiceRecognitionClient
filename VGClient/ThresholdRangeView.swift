//
//  ThresholdRangeView.swift
//  VGClient
//
//  Created by viwii on 2017/4/14.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

enum ThresholdMaskPosition: Int {
    case low = -1
    case normal = 0
    case high = 1
}

class ThresholdRangeView: UIView {

    // MARK: - Properties
    
    @IBInspectable var normalColor: UIColor = .lightGray
    
    @IBInspectable var highlightColor: UIColor = .black
    
    @IBInspectable var lineWidth: CGFloat = 2.0

    /// 标记
    
    @IBInspectable var maskPosition: Int = 2 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var maskFillColor: UIColor = .green
    
    @IBInspectable var maskRadius: CGFloat = 8.0
    
    private var _maskPosition: ThresholdMaskPosition? {
        return ThresholdMaskPosition(rawValue: self.maskPosition)
    }
    
    /// Range
    
    @IBInspectable var textWidth: CGFloat = 20.0
    
    @IBInspectable var lowText: String? {
        didSet {
            lowLabel.text = lowText ?? ""
        }
    }
    
    @IBInspectable var highText: String? {
        didSet {
            highLabel.text = highText ?? ""
        }
    }
    
    private var lowLabel: UILabel!
    
    private var highLabel: UILabel!
    
    ///
    
    private var length: CGFloat {
        return (frame.width - 6 * lineWidth) / 3.0
    }
    
    private var middleY: CGFloat {
        return (frame.height - lineWidth) * 0.5
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initial()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initial()
    }
    
    private func initial() {
        
        func alabel(text: String?) -> UILabel {
            let lab = UILabel()
            lab.translatesAutoresizingMaskIntoConstraints = false
            lab.font = UIFont.systemFont(ofSize: 12)
            lab.text = text ?? ""
            addSubview(lab)
            return lab
        }
        
        let llab = alabel(text: lowText)
        let hlab = alabel(text: highText)
        
        let w = textWidth
        let c = middleY
        let l = length
        
        let top = c + 2.0 * lineWidth + 4.0
        let lowleading = l + 1.5 * lineWidth - w * 0.5
        let highleading = 2 * l + 4.5 * lineWidth - w * 0.5
        
        let metrics = ["ll":lowleading, "t":top, "hl":highleading]
        let views = ["lv":llab, "hv":hlab]
        
        addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-(ll)-[lv]", options: [], metrics: metrics, views: views) +
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-(hl)-[hv]", options: [], metrics: metrics, views: views) +
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-(t)-[lv]", options: [], metrics: metrics, views: views) +
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-(t)-[hv]", options: [], metrics: metrics, views: views)
        )
        
        lowLabel = llab
        highLabel = hlab
    }
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        let w = frame.width
        let l = length
        let c = middleY
        
        /// 数轴
        
        /// segment 1
        ctx.beginPath()
        ctx.setLineWidth(lineWidth)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        ctx.setStrokeColor(normalColor.cgColor)
        
        ctx.move(to: CGPoint(x: 0, y: c))
        ctx.addLine(to: CGPoint(x: l, y: c))
        
        ctx.strokePath()

        let l1 = l + 1.5 * lineWidth
        ctx.move(to: CGPoint(x: l1, y: c - lineWidth))
        ctx.addLine(to: CGPoint(x: l1, y: c + lineWidth))
        
        ctx.strokePath()
        
        /// segment 2
        ctx.setStrokeColor(highlightColor.cgColor)
        
        ctx.move(to: CGPoint(x: l + 3 * lineWidth, y: c))
        ctx.addLine(to: CGPoint(x: 2 * l + 3 * lineWidth, y: c))
        
        ctx.strokePath()

        /// segment 3
        ctx.setStrokeColor(normalColor.cgColor)
        
        let l2 = 2 * l + 4.5 * lineWidth
        ctx.move(to: CGPoint(x: l2, y: c - lineWidth))
        ctx.addLine(to: CGPoint(x: l2, y: c + lineWidth))
        
        ctx.move(to: CGPoint(x: 2 * l + 6 * lineWidth, y: c))
        ctx.addLine(to: CGPoint(x: w, y: c))
        
        ctx.strokePath()
        
        /// 标记点
        
        guard let p = _maskPosition else { return }
        
        let cm = CGPoint(x: frame.width * 0.5 + CGFloat(p.rawValue) * l, y: c)
        
        ctx.beginPath()
        
        ctx.setFillColor(maskFillColor.cgColor)
        
        ctx.move(to: cm)
        ctx.addArc(center: cm, radius: maskRadius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)
        
        ctx.fillPath()
    }

}
