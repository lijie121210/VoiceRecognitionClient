//
//  AudioRecognitionParser.swift
//  VGClient
//
//  Created by viwii on 2017/4/18.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation


extension String {
    
    /// 数组中第一个被找到的元素的索引被返回
    func range(of arr: [String]) -> (Range<String.Index>, Int)? {
        for str in arr {
            if contains(str) {
                if let r = range(of: str) {
                    return (r, arr.index(of: str)!)
                }
            }
        }
        return nil
    }
}


enum AudioRecognizerParserResult {
    
    case refreshAll
    
    case refresh(MeasurementType)
    
    /// 定时任务只针对 打开 操作
    case open(Int?, AccessoryType, TimeInterval?)
    
    case close(Int?, AccessoryType)
    
    case stop(Int?, AccessoryType)
    
    var accessoryType: AccessoryType? {
        switch self {
        case .refresh(_), .refreshAll:  return nil
        case let .open(_, t, _):        return t
        case let .close(_, t):          return t
        case let .stop(_, t):           return t
        }
    }
    
    var name: String {
        let item = { (n:Int?, t: AccessoryType) -> String in
            var short = ""
            if let num = n {
                short += "\(num)号"
            }
            short += t.name
            return short
        }
        switch self {
        case .refreshAll, .refresh(_):  return ""
        case let .open(n, t, _):        return item(n,t)
        case let .close(n, t):          return item(n,t)
        case let .stop(n, t):           return item(n,t)
        }
    }
    
    var description: String {
        let item = { (n:Int?, t: AccessoryType, tim: TimeInterval?) -> String in
            var long = ""
            if let num = n {
                long += "\(num)号"
            }
            long += t.name
            if let t = tim {
                long += " \(t)分钟"
            }
            return long
        }
        switch self {
        case .refreshAll, .refresh(_):  return ""
        case let .open(n, t, tim):      return "打开 " + item(n,t, tim)
        case let .close(n, t):          return "关闭 " + item(n,t, nil)
        case let .stop(n, t):           return "停止 " + item(n,t, nil)
        }
    }
    
    var timeInterval: TimeInterval? {
        switch self {
        case .refreshAll, .refresh(_):  return nil
        case let .open(_, _, tim):      return tim
        case .close(_, _):          return nil
        case .stop(_, _):           return nil
        }
    }
}

fileprivate struct Keywords {
    static let openKeywords = ["打开","开启","启动","开始"]
    
    static let closeKeywords = ["关闭","关停","关掉"]
    
    static let stopKeywords = ["停止","暂停"]
    
    static let accessoryKeywords = ["卷帘机","浇灌泵","通风机","增温灯","补光灯"]
    
    static let refresh = ["刷新","更新"]
    
    static let refreshTarget = ["空气湿度","空气温度","土壤湿度","土壤温度","CO2浓度","光照强度"]
    
    static let refreshIntegrated = ["综合","数据","状态","所有","全部"]
    
    static let sequence = stride(from: 1, through: 100, by: 1)
}



struct AudioRecognizerParser {
    
    var text: String
    
    init(text: String) {
        self.text = text
    }
    
    /// 首先确定是那种操作：刷新；打开；关闭；停止
    func parse() throws -> AudioRecognizerParserResult {
        if let r = text.range(of: Keywords.refresh) {
            return try refresh(text: text, index: r.0)
        } else if let r = text.range(of: Keywords.openKeywords) {
            return try open(text: text, index: r.0)
        } else if let r = text.range(of: Keywords.closeKeywords) {
            return try close(text: text, index: r.0)
        } else if let r = text.range(of: Keywords.stopKeywords) {
            return try stop(text: text, index: r.0)
        } else {
            throw VGError.recognizeFailure
        }
    }
    
    /// 刷新，检查刷新特定项，还是全部刷新
    func refresh(text: String, index: Range<String.Index>) throws -> AudioRecognizerParserResult {
        let substr = text.substring(from: index.upperBound)
        if let r = substr.range(of: Keywords.refreshTarget) {
            guard let type = MeasurementType(textDescription: Keywords.refreshTarget[r.1]) else {
                throw VGError.recordFailure
            }
            return .refresh(type)
        }
        return .refreshAll
    }
    
    /// 打开，检查打开对象，打开对象包括编号和名称（1号增温灯）；然后检查打开时间；
    func open(text: String, index: Range<String.Index>) throws -> AudioRecognizerParserResult {
        let substr = text.substring(from: index.upperBound)
        
        guard
            let r = substr.range(of: Keywords.accessoryKeywords),
            let type = AccessoryType(name: Keywords.accessoryKeywords[r.1]) else {
                throw VGError.recognizeFailure
        }
        
        let st = findSequenceAndTime(in: substr, keywordRange: r.0)
        
        return .open(st.0, type, st.1)
    }
    
    func close(text: String, index: Range<String.Index>) throws -> AudioRecognizerParserResult {
        let substr = text.substring(from: index.upperBound)

        guard
            let r = substr.range(of: Keywords.accessoryKeywords),
            let type = AccessoryType(name: Keywords.accessoryKeywords[r.1]) else {
                throw VGError.recognizeFailure
        }
        
        let st = findSequenceAndTime(in: substr, keywordRange: r.0)
        
        return .close(st.0, type)
    }
    
    func stop(text: String, index: Range<String.Index>) throws -> AudioRecognizerParserResult {
        let substr = text.substring(from: index.upperBound)
        
        guard
            let r = substr.range(of: Keywords.accessoryKeywords),
            let type = AccessoryType(name: Keywords.accessoryKeywords[r.1]),
            type == .rollingMachine else {
                throw VGError.recognizeFailure
        }
        
        let st = findSequenceAndTime(in: substr, keywordRange: r.0)
        
        return .stop(st.0, type)
    }
    
    /// `编号`和`时间`的位置应分别在名称的前后两侧；并且处于1-100之间
    func findSequenceAndTime(in substr: String, keywordRange r: Range<String.Index>) -> (Int?,TimeInterval?) {
        /// <打开>-seqstr-设备-timstr-。
        let seqstr = substr.substring(to: r.lowerBound)
        let timstr = substr.substring(from: r.upperBound)
        
        print(seqstr, timstr)

        var s:Int? = nil
        let seqw = Keywords.sequence.map{ "\($0)号" }
        if let sr = seqstr.range(of: seqw) {
            let seqs = seqw[sr.1]
            /// 去掉最后的 `号` 字就是序号
            s = Int(seqs.substring(to: seqs.index(before: seqs.endIndex)))
        }

        var t:TimeInterval? = nil
        let timew = Keywords.sequence.map{ "\($0)分钟" }
        if let tr = timstr.range(of: timew) {
            let tims = timew[tr.1]
            /// 去掉最后的 `分钟` 就是序号
            t = TimeInterval(tims.substring(to: tims.index(tims.endIndex, offsetBy: -2)))
        }
        
        return (s,t)
    }
}
