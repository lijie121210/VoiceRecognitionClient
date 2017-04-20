//
//  RCView.swift
//  VGClient
//
//  Created by viwii on 2017/4/17.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

///
//struct RoundCorner: OptionSet {
//    
//    let rawValue: UInt
//    
//    init(rawValue: UInt) {
//        self.rawValue = rawValue
//    }
//    /// 0001 1
//    static let topLeft = RoundCorner(rawValue: 1<<0)
//    /// 0010 2
//    static let topRight = RoundCorner(rawValue: 1<<1)
//    /// 0100 4
//    static let bottomLeft = RoundCorner(rawValue: 1<<2)
//    /// 1000 8
//    static let bottomRight = RoundCorner(rawValue: 1<<3)
//    /// 0011 3
//    static let top: RoundCorner = [.topLeft, .topRight]
//    /// 1100 12
//    static let bottom: RoundCorner = [.bottomLeft, .bottomRight]
//    /// 1111 15
//    static let all: RoundCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
//}

@IBDesignable class RCView: UIControl {
    
    /// Background Color
    @IBInspectable var fillColor: UIColor = .white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Corner Radius X
    @IBInspectable var xcradius: CGFloat = 20.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    /// Corner Radius Y
    @IBInspectable var ycradius: CGFloat = 20.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Which corner should cut into rounded
    @IBInspectable var corner: UInt = 15 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Shadow
    
    /// silver - 214; magnesium - 191; aluminum - 192
    
    @IBInspectable var isShadow: Bool = true
    
    @IBInspectable var scolor: UIColor = UIColor(red: 191 / 255.0, green: 191 / 255.0, blue: 191 / 255.0, alpha: 1) {
        didSet {
            addShadow()
        }
    }
    
    @IBInspectable var sradius: CGFloat = 8.0 {
        didSet {
            addShadow()
        }
    }
    
    @IBInspectable var sopacity: Float = 0.4 {
        didSet {
            addShadow()
        }
    }
    
    @IBInspectable var soffsetX: CGFloat = 0 {
        didSet {
            addShadow()
        }
    }
    
    @IBInspectable var soffsetY: CGFloat = 0 {
        didSet {
            addShadow()
        }
    }
    
    /// For button
    
    @IBInspectable var text: String? {
        didSet {
            if let btn = self.button {
                btn.setTitle(text, for: .normal)
            }
        }
    }
    
    @IBInspectable var textColor: UIColor = .black {
        didSet {
            if let btn = self.button {
                btn.setTitleColor(textColor, for: .normal)
            }
        }
    }
    
    @IBInspectable var image: UIImage? = nil {
        didSet {
            if let btn = self.button {
                btn.setImage(image, for: .normal)
            }
        }
    }
    
    /// make rect corner
    private var rectCorner: UIRectCorner {
        return UIRectCorner(rawValue: corner)
    }
    
    var button: UIButton!
    
    
    // MARK: - Life cycle
    
    deinit {
        print("RCView", #function)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        initialization()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialization()
    }
    func initialization() {
        let btn = UIButton(frame: CGRect.zero)
        btn.isEnabled = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitleColor(textColor, for: .normal)
        btn.setTitle(text, for: .normal)
        btn.setImage(image, for: .normal)
        btn.addTarget(self, action: #selector(RCView.touchUpInside(_:)), for: .touchUpInside)
        btn.layer.cornerRadius = xcradius >= ycradius ? xcradius : ycradius
        addSubview(btn)
        let views = ["v":btn]
        addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[v]-(0)-|", options: [], metrics: nil, views: views) +
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[v]-(0)-|", options: [], metrics: nil, views: views)
        )
        button = btn
        
        if isShadow {
            addShadow()
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if let new = newSuperview {
            super.willMove(toSuperview: new)
        }
        if let btn = button {
            btn.removeTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
            btn.removeFromSuperview()
            button = nil
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.saveGState()
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: rectCorner,
                                cornerRadii: CGSize(width: xcradius, height: ycradius))
        ctx.beginPath()
        ctx.addPath(path.cgPath)
        ctx.setFillColor(fillColor.cgColor)
        ctx.fillPath()
        ctx.restoreGState()
    }
    
    // MARK: -  Shadow
    
    func addShadow() {
        layer.shadowColor = scolor.cgColor
        layer.shadowOffset = CGSize(width: soffsetX, height: soffsetY)
        layer.shadowRadius = sradius
        layer.shadowOpacity = sopacity
    }
    
    func removeShadow() {
        layer.shadowColor = nil
        layer.shadowOpacity = 0.0
    }
    
    // MARK: - Action
    
    func touchUpInside(_ sender: Any) {
        sendActions(for: .touchUpInside)
    }
    
//    override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControlEvents) {
//        button.addTarget(target, action: action, for: controlEvents)
//    }
//    
//    override func removeTarget(_ target: Any?, action: Selector?, for controlEvents: UIControlEvents) {
//        button.removeTarget(target, action: action, for: controlEvents)
//    }
}
