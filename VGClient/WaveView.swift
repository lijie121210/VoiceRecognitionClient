//
//  WaveView.swift
//  VGClient
//
//  Created by jie on 2017/3/12.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//
///
/// From: https://github.com/kevinzhow/Waver
/// Modified some place that not understandable in the original design

import UIKit

@IBDesignable
open class WaveView: UIView {

    @IBInspectable open var numberOfWaves: Int = 5
    
    @IBInspectable open var waveColor: UIColor = .blue
    
    @IBInspectable open var mainWaveWidth: CGFloat = 2.0
    
    @IBInspectable open var decorativeWavesWidth: CGFloat = 1.0
    
    @IBInspectable open var idleAmplitude: CGFloat = 0.01
    
    @IBInspectable open var frequency: CGFloat = 1.2
    
    @IBInspectable open var density: CGFloat = 1.0
    
    @IBInspectable open var phaseShift: CGFloat = -0.25

    fileprivate var displayLink: CADisplayLink!

    fileprivate var waves: [CAShapeLayer] = []
    
    fileprivate var amplitude: CGFloat = 1.0
    
    fileprivate var phase: CGFloat = 0
    
    /// 计算属性
    
    fileprivate var waveHeight: CGFloat { return self.bounds.height }
    
    fileprivate var waveWidth: CGFloat { return self.bounds.width }
    
    fileprivate var waveMid: CGFloat { return self.waveWidth * 0.5 }
    
    fileprivate var maxAmplitude: CGFloat { return self.waveHeight - 4.0 }
    
    
    /// 直接设置，则不需要设置回调函数
    
    open var level: Float = 0 {
        didSet {
            updateMeters(with: level)
        }
    }
    
    
    /// 使用回调，则只需要在回调中返回幅度值，而不需要直接设置; 但是需要调用func start() 启动displaylink
    
    open var updateWaveLevel: ( () -> Float )?
    
    open func start() -> Bool {
        
        guard let _ = updateWaveLevel, numberOfWaves > 0 else {
            return false
        }
        
        setupDisplayLink()
        
        return true
    }
    
    
    /// 尝试 func awakeFromNib() 自动调用
    
    open func prepareForWaving() {
        guard numberOfWaves > 0 else {
            return
        }
        for i in 0 ..< numberOfWaves {
            
            let progress = 1.0 - CGFloat(i) / CGFloat(numberOfWaves)
            
            let multiplier = min(1.0, (progress / 3.0 * 2.0) + (1.0 / 3.0))
            
            let color = waveColor.withAlphaComponent(i == 0 ? 1.0 : 1.0 * multiplier * 0.4)
            
            let line = CAShapeLayer()
            line.lineCap = kCALineCapButt
            line.lineJoin = kCALineJoinRound
            line.strokeColor = UIColor.clear.cgColor
            line.fillColor = UIColor.clear.cgColor
            line.lineWidth = i == 0 ? mainWaveWidth : decorativeWavesWidth
            line.strokeColor = color.cgColor
            
            layer.addSublayer(line)
            
            waves.append(line)
        }
    }
    
    fileprivate func setupDisplayLink() {
        if let link = self.displayLink {
            link.invalidate()
        }
        
        displayLink = CADisplayLink(target: self, selector: #selector(WaveView.invokeWaveCallback))
        displayLink.add(to: .current, forMode: .commonModes)
    }
    
    
    
    /// Called by displaylink
    @objc fileprivate func invokeWaveCallback() {
        
        level = updateWaveLevel?() ?? 0
    }
    
    fileprivate func updateMeters(with level: Float) {
        
        phase += phaseShift
        
        amplitude = fmax(CGFloat(level), idleAmplitude)
        
        updateMeters()
    }
    
    /// 绘制图形
    fileprivate func updateMeters() {
        
        guard numberOfWaves > 0 else {
            return
        }
        
        /// The begin
        
        UIGraphicsBeginImageContext(self.frame.size)
        
        
        for i in 0 ..< numberOfWaves {
            
            let linePath = UIBezierPath()
            
            let progress = 1.0 - CGFloat(i) / CGFloat(numberOfWaves)
            
            let normedAmplitude = (1.5 * progress - 0.5) * amplitude
            
            var x: CGFloat = 0
            
            while x < waveWidth + density {
                
                let scaling = -pow(x / waveMid - 1, 2) + 1
                
                let si = 2 * CGFloat.pi * (x / waveWidth) * frequency * phase
                
                let y = scaling * maxAmplitude * normedAmplitude * CGFloat(sinf(Float(si))) + waveHeight * 0.5
                
                let point = CGPoint(x: x, y: y)
                
                if x == 0 {
                    
                    linePath.move(to: point)
                    
                } else {
                    
                    linePath.addLine(to: point)
                }
                
                x += density
            }
            
            let line = waves[i]
            
            line.path = linePath.cgPath

            waves.replaceSubrange((i..<i+1), with: [line])
        }
        
        
        /// The end
        
        UIGraphicsEndImageContext()
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        
        prepareForWaving()
    }
    
    deinit {
        
        print(self, #function)
        
        if let link = displayLink {
            link.invalidate()
        }
        
        displayLink = nil
    }
}
