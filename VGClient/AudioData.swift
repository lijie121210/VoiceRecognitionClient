//
//  AudioData.swift
//  VGClient
//
//  Created by jie on 2017/2/21.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation

/// Record data model
public struct AudioData: Equatable {
    
    public let filename: String
    public let duration: TimeInterval
    public let recordDate: Date
    public var translation: String? = nil
    
    public init(filename: String, duration: TimeInterval, recordDate: Date, translation: String? = nil) {
        self.filename = filename
        self.duration = duration
        self.recordDate = recordDate
        self.translation = translation
    }
}

public func ==(lhs: AudioData, rhs: AudioData) -> Bool {
    return lhs.filename == rhs.filename && lhs.duration == rhs.duration && lhs.recordDate == rhs.recordDate
}


public extension AudioData {
    
    /// local url for search file in current bundle.
    public var localURL: URL {
        return FileManager.dataURL(with: self.filename)
    }
    
    /// get the audio record data of this AudioData
    public var data: Data? {
        return try? Data(contentsOf: localURL)
    }
}


/// Manage local directory.
public extension FileManager {
    
    /// folder name.
    public static let dataDirectoryName = "audio_record_files"
    
    /// folder url path.
    public static var dataStorageDirectory: URL {
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent(dataDirectoryName)
    }
    
    /// folder creation.
    public static func initAudioDataStorageDirectory() {
        
        if FileManager.default.fileExists(atPath: dataStorageDirectory.path) {
            return
        }
        do {
            try FileManager.default.createDirectory(at: dataStorageDirectory, withIntermediateDirectories: false, attributes: nil)
        } catch {
            print(#function, error.localizedDescription)
        }
    }
    
    /// specified data url path in the folder.
    public static func dataURL(with fileName: String) -> URL {
        
        return dataStorageDirectory.appendingPathComponent(fileName)
    }
}


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


/// A formatted output style to show audio data duration.
public extension TimeInterval {
    
    /// 用迭代重写!
    
    public var timeDescription: String {
        
        if self < 0 {
            return "--:--"
        }
        
        let _d: TimeInterval = 24 * 60 * 60
        let _h: TimeInterval = 60 * 60
        let _m: TimeInterval = 60
        let _s: TimeInterval = 1
        
        var res = ""
        
        var v = self
        
        var dx: Int = Int(v / _d)
        
        if dx >= 10 {
            res.append("\(dx)天 ")
        } else if dx > 0 {
            res.append("0\(dx)天 ")
        }
        
        /// handle hour
        
        v = v - TimeInterval(dx) * _d
        
        dx = Int(v / _h)
        
        if dx < 10 {
            res.append("0\(dx):")
        } else {
            res.append("\(dx):")
        }
        
        /// handle minute
        
        v = v - TimeInterval(dx) * _h
        
        dx = Int(v / _m)
        
        if dx < 10 {
            res.append("0\(dx):")
        } else {
            res.append("\(dx):")
        }
        
        /// handle second
        
        v = v - TimeInterval(dx) * _m
        
        dx = Int(v / _s)
        
        if dx < 10 {
            res.append("0\(dx)")
        } else {
            res.append("\(dx)")
        }
        
        return res
    }
    
}
