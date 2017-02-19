//
//  AudioController.swift
//  VGClient
//
//  Created by jie on 2017/2/12.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import AVFoundation
import CoreData


struct AudioData: Equatable {
    
    let filename: String
    let duration: TimeInterval
    let recordDate: Date
    
    var translation: String? = nil
    
    var localURL: URL {
        return AudioDataManager.dataURL(with: self.filename)
    }
    
    var data: Data? {
        return try? Data(contentsOf: localURL)
    }
    
    init(filename: String, duration: TimeInterval, recordDate: Date) {
        self.filename = filename
        self.duration = duration
        self.recordDate = recordDate
    }
}

func ==(lhs: AudioData, rhs: AudioData) -> Bool {
    return lhs.filename == rhs.filename && lhs.duration == rhs.duration && lhs.recordDate == rhs.recordDate
}



struct AudioDataManager {
    
    var datas: [AudioData] = []
    
    var currentData: AudioData? = nil
    
    mutating func loadLocalData() {
        
        var result = [AudioRecordItem]()
        
        let request = NSFetchRequest<AudioRecordItem>(entityName: "AudioRecordItem")
        let context = CoreDataManager.default.managedObjectContext
        
        context.performAndWait {
            do {
                result = try context.fetch( request )
            } catch {
                print(#function, error.localizedDescription)
            }
        }
        let resultDatas = result.map {
            return AudioData(filename: $0.filename!, duration: $0.duration,recordDate: $0.createDate as! Date)
        }
        
        datas.append(contentsOf: resultDatas)
    }
    
    mutating func append(newData: (String, Date, TimeInterval)?) {
        
        let data = updateCurrentData(newData: newData)

        if let d = data {
            datas.append(d)
            
            CoreDataManager.default.append(data: d)
        }
    }
    
    
    @discardableResult
    mutating func updateCurrentData(newData: (String, Date, TimeInterval)?) -> AudioData? {
        var data: AudioData? = nil
        
        if let r = newData {
            data = AudioData(filename: r.0, duration: r.2, recordDate: r.1)
        }
        
        currentData = data
        
        return data
    }
    
    @discardableResult
    mutating func remove(at index: Int) -> Bool {
        
        guard index >= 0, index < datas.count else {
            return false
        }

        let data = datas[index]
        
        do {
            try FileManager.default.removeItem(at: data.localURL)
        } catch {
            print(#function, "Fail to remove. <\(error.localizedDescription)>")
            return false
        }
        
        CoreDataManager.default.remove(data: data)

        datas.remove(at: index)
        
        return true
    }
}

extension AudioDataManager {
    
    func initConnection() {
        
        AudioUploader.default.connect()
    }
    
    func upload(data: AudioData, progression: AudioClientProgressHandler?, completion: AudioClientCompletionHandler?) {
        
        AudioUploader.default.upload(data: data, progression: progression, completion: completion)
    }
    
}

extension AudioDataManager {
    
    func play(record: AudioData, completion: ( (AudioPlayer, Bool) -> () )? = nil) {
        
        AudioPlayer.sharedPlayer.startPlaying(url: record.localURL, completion: completion)
    }
    
    func stopPlaying() {
        
        AudioPlayer.sharedPlayer.stopPlaying()
    }
}

extension AudioDataManager {

    static let dataDirectoryName = "audio_record_files"

    static var dataStorageDirectory: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent(dataDirectoryName)
    }
    
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
    
    static func dataURL(with fileName: String) -> URL {
        return dataStorageDirectory.appendingPathComponent(fileName)
    }
}




