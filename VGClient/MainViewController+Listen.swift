//
//  MainViewController+Listen.swift
//  VGClient
//
//  Created by viwii on 2017/4/18.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UIKit

/// 处理语音识别的结果
/// 从ListenViewController接收代理事件的转发，再经由didRecognizedSpeech转发到具体的执行函数；
///
extension MainViewController {
    
    ///
    
    func dismiss(_ orbit: OrbitAlertController?, with str: String) {
        orbit?.update(prompt: str)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            orbit?.dismiss(animated: true, completion: nil)
        })
    }
    
    ///
    
    func refreshAll(_ orbit: OrbitAlertController?) {
        MeasurementManager.default.refreshAll(handler: { (finish) in
            DispatchQueue.main.async {
                if finish {
                    self.dismiss(orbit, with: "更新完成")
                    self.measurementCollectionView.reloadData()
                    self.updateLineChartView()
                } else {
                    self.dismiss(orbit, with: "更新失败")
                }
            }
        })
    }
    
    func refresh(_ t: MeasurementType, _ orbit: OrbitAlertController?) {
        orbit?.update(prompt: "更新\(t.textDescription)")
        MeasurementManager.default.refreshAll(handler: { (finish) in
            DispatchQueue.main.async {
                if finish {
                    self.dismiss(orbit, with: "更新完成")
                    self.measurementCollectionView.reloadData()
                    self.updateLineChartView()
                } else {
                    self.dismiss(orbit, with: "更新失败")
                }
            }
        })
    }
    
    func open(_ orbit: OrbitAlertController?, result: AudioRecognizerParserResult, timeInterval: TimeInterval?) {
        guard let type = result.accessoryType else {
            orbit?.update(prompt: "设备类型解析失败")
            orbit?.dismiss(animated: true, completion: nil)
            return
        }
        
        var data = AccessoryData(type: type, state: .opened, name: result.name)
        
        orbit?.update(prompt: result.description)
        
        guard AccessoryManager.default.accessoryDatas.contains(data),
            let index = AccessoryManager.default.accessoryDatas.index(of: data) else {
                orbit?.update(prompt: "设备列表中找不到：" + result.name)
                orbit?.dismiss(animated: true, completion: nil)
                return
        }
        
        guard AccessoryManager.default.accessoryDatas[index].state != .opened else {
            orbit?.update(prompt: "放弃任务, 设备已打开" + result.name)
            orbit?.dismiss(animated: true, completion: nil)
            return
        }
        
        if let timeInterval = timeInterval {
            data.isTimed = true
            
            /// schadule a notifier
            let noti = VGNotification(title: "提示", body: result.description + "定时任务完成", lunchImageName: "notification")
            noti.schedule(minute: Int(timeInterval), userInfo: ["name":result.name,"timeInterval":timeInterval])
        }
        AccessoryManager.default.accessoryDatas.replaceSubrange((index..<index+1), with: [data])
        update(accessoryCollectionView, indexPaths: [IndexPath(item: index, section: 0)], orbit: orbit)
    }
    
    func close(_ orbit: OrbitAlertController?, result: AudioRecognizerParserResult) {
        guard let type = result.accessoryType else {
            orbit?.update(prompt: "设备类型解析失败")
            orbit?.dismiss(animated: true, completion: nil)
            return
        }
        
        let data = AccessoryData(type: type, state: .closed, name: result.name)
        
        orbit?.update(prompt: result.description)
        
        guard AccessoryManager.default.accessoryDatas.contains(data),
            let index = AccessoryManager.default.accessoryDatas.index(of: data) else {
                orbit?.update(prompt: "设备列表中找不到：" + result.name)
                orbit?.dismiss(animated: true, completion: nil)
                return
        }
        
        guard AccessoryManager.default.accessoryDatas[index].state != .closed else {
            orbit?.update(prompt: "放弃任务, 设备已关闭" + result.name)
            orbit?.dismiss(animated: true, completion: nil)
            return
        }
        
        AccessoryManager.default.accessoryDatas.replaceSubrange((index..<index+1), with: [data])
        update(accessoryCollectionView, indexPaths: [IndexPath(item: index, section: 0)], orbit: orbit)
    }
    
    func stop(_ orbit: OrbitAlertController?, result: AudioRecognizerParserResult) {
        guard let type = result.accessoryType, type == .rollingMachine else {
            orbit?.update(prompt: "放弃任务, 只有卷帘机可以暂停" + result.name)
            orbit?.dismiss(animated: true, completion: nil)
            return
        }
        
        let data = AccessoryData(type: type, state: .stopped, name: result.name)
        
        orbit?.update(prompt: result.description)
        
        guard AccessoryManager.default.accessoryDatas.contains(data),
            let index = AccessoryManager.default.accessoryDatas.index(of: data) else {
                orbit?.update(prompt: "设备列表中找不到：" + result.name)
                orbit?.dismiss(animated: true, completion: nil)
                return
        }
        
        guard AccessoryManager.default.accessoryDatas[index].state != .closed else {
            orbit?.update(prompt: "放弃任务, 设备已关闭" + result.name)
            orbit?.dismiss(animated: true, completion: nil)
            return
        }
        
        AccessoryManager.default.accessoryDatas.replaceSubrange((index..<index+1), with: [data])
        update(accessoryCollectionView, indexPaths: [IndexPath(item: index, section: 0)], orbit: orbit)
    }
    
    /// 
    
    func didRecognizedSpeech(result: String) {
        let orbit = OrbitAlertController.show(with: "[\(result)]解析中", on: self)
        
        let res: AudioRecognizerParserResult
        do {
            res = try AudioRecognizerParser(text: result).parse()
        } catch {
            dismiss(orbit, with: "无法生成命令")
            return
        }
        
        switch res {
        case .refreshAll: refreshAll(orbit)
        case .refresh(let t): refresh(t, orbit)
        case let .open(_, _, time): open(orbit, result: res, timeInterval: time)
        case .close(_, _): close(orbit, result: res)
        case .stop(_, _): stop(orbit, result: res)
        }
    }
}
