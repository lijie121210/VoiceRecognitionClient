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
    
    /// may be nil very much
    public var translation: String? = nil
    
    /// local url for search file in current bundle.
    public var localURL: URL {
        return AudioDataManager.dataURL(with: self.filename)
    }
    
    /// get the audio record data of this AudioData
    public var data: Data? {
        return try? Data(contentsOf: localURL)
    }
    
    public init(filename: String, duration: TimeInterval, recordDate: Date) {
        self.filename = filename
        self.duration = duration
        self.recordDate = recordDate
    }
}

public func ==(lhs: AudioData, rhs: AudioData) -> Bool {
    return lhs.filename == rhs.filename && lhs.duration == rhs.duration && lhs.recordDate == rhs.recordDate
}
