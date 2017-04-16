//
//  DateEx.swift
//  VGClient
//
//  Created by viwii on 2017/3/25.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation


public extension Date {
    
    /// A formatted string from current date.
    /// use as filename for audio data
    public static var currentName: String {
        
        let formatterString = DateFormatter.localizedString(from: Date(),
                                                            dateStyle: .short,
                                                            timeStyle: .long)
        
        let res = formatterString.replacingOccurrences(of: " ", with: "a")
            .replacingOccurrences(of: "/", with: "b")
            .replacingOccurrences(of: "+", with: "c")
            .replacingOccurrences(of: ":", with: "d")
            .replacingOccurrences(of: ",", with: "e")
        
        return res
    }
    
    /// A formatted string from current date.
    /// use when showing audio data createDate on a cell
    public var recordDescription: String {
        
        return DateFormatter.localizedString(from: self,
                                             dateStyle: .long,
                                             timeStyle: .long)
            .replacingOccurrences(of: "GMT+8", with: "")
    }
}

enum DateConvertError: Error {
    case invalidFormat
}

extension String {
    
    /// String format: yyyy-MM-dd HH:mm:ss
    ///
    func date() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: self)
    }
    
    func dateTimeIntervalFrom1970() throws -> Double {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = dateFormatter.date(from: self) else {
            throw DateConvertError.invalidFormat
        }
        return date.timeIntervalSince1970
    }
    
    
    func dateComponents() -> DateComponents? {
        guard let date = date() else {
            return nil
        }
        
        let com = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        return com
    }
}
