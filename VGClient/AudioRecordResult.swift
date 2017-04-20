//
//  AudioRecordResult.swift
//  VGClient
//
//  Created by viwii on 2017/4/17.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation


/// Manage local directory.
extension FileManager {
    
    /// folder name.
    static let dataDirectoryName = "audio_record_files"
    
    /// folder url path.
    static var dataStorageDirectory: URL {
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent(dataDirectoryName)
    }
    
    /// folder creation.
    static func initAudioDataStorageDirectory() {
        
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
    static func dataURL(with fileName: String) -> URL {
        
        return dataStorageDirectory.appendingPathComponent(fileName)
    }
}


final class AudioRecordResult: NSObject {
    
    var filename: String
    var duration: TimeInterval
    var recordDate: Date
    var translation: String? = nil
    
    /// local url for search file in current bundle.
    var localURL: URL {
        return FileManager.dataURL(with: self.filename)
    }
    
    /// get the audio record data of this AudioData
    var data: Data? {
        return try? Data(contentsOf: localURL)
    }
    
    override init() {
        self.filename = ""
        self.duration = 0
        self.recordDate = Date()
        super.init()
    }
    
    init(filename: String, duration: TimeInterval, recordDate: Date) {
        self.filename = filename
        self.duration = duration
        self.recordDate = recordDate
        super.init()
    }
}
