//
//  AudioModel.swift
//  VGClient
//
//  Created by jie on 2017/2/21.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit
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


/** Manage a bunch of certain types <AudioData> of data.
 Thread safe.
 Responsible for communication with the database.
 */
public class AudioDataSource {
    
    /// Temporarily save the data currently being manipulated.
    public var currentData: AudioData? = nil
    
    /// All datas in memory.
    fileprivate var datas: [AudioData] = []
    
    /** A private serial queue facilitates the security of data operations.
     1. default parameter attributes == .serial .
     2. queue will not hold self after it's task block is done.
     3. DispatchWorkItem(...).perform() will execute code sync .
     */
    fileprivate var queue: DispatchQueue = DispatchQueue(label: "com.vg.client.model")
    
    fileprivate var key: DispatchSpecificKey<String> = DispatchSpecificKey<String>()
    
    init() {        
        queue.setSpecific(key: key, value: "com.vg.client.onqueue.key")
    }
    
    /** This two ensure that the code is executed in the specified queue.
     If it is called on the queue, the code will be executed sequentially, otherwise, 
     the code can be executed sync or async ...
     */
    func dispatchOnQueue(execute: @escaping () -> ()) {
        if let _ = DispatchQueue.getSpecific(key: key) {
            execute()
        } else {
            queue.async(execute: execute)
        }
    }
    
    func syncDispatchOnQueue(execute: @escaping () -> ()) {
        if let _ = DispatchQueue.getSpecific(key: key) {
            execute()
        } else {
            queue.sync(execute: execute)
        }
    }
    
    /// Load data from local database.
    public func loadLocalData(completion: @escaping (Bool, [AudioData]) -> ()) {
        
        let workitem = {

            let items: [AudioRecordItem] = CoreDataManager.default.fetch()
            
            let result = items.map { AudioData(filename: $0.filename!, duration: $0.duration, recordDate: $0.createDate as! Date) }
            
            self.datas.append(contentsOf: result)
            
            completion(true, result)
        }
        
        dispatchOnQueue(execute: workitem)
    }
    
    /// The code will be executed synchronously, and the self.datas will be set after execution.
    public func loadLocalData() {
        
        let workitem = {
            
            let items: [AudioRecordItem] = CoreDataManager.default.fetch()
            
            let result = items.map { AudioData(filename: $0.filename!, duration: $0.duration, recordDate: $0.createDate as! Date) }
            
            self.datas.append(contentsOf: result)
        }
        
        syncDispatchOnQueue(execute: workitem)
    }
    
    public func append(data: AudioData) {
        
        let workitem = {
            
            self.currentData = data
            
            self.datas.append(data)
            
            CoreDataManager.default.insert(data: data)
        }
        
        syncDispatchOnQueue(execute: workitem)
    }
    
    public func setCurrentData(data: AudioData?) {
        
        let workitem = {
            self.currentData = data
        }
        
        syncDispatchOnQueue(execute: workitem)
    }
    
    public func remove(at index: Int, completion: @escaping (Bool) -> ()) {
        
        let workitem = {
            guard index >= 0, index < self.datas.count else {
                
                print(self, #function, "index invalid <\(index)>")
                completion(false)
                return
            }
            let data = self.datas[index]
            
            /// remove local file first,
            /// if failed, possible reason is that the path is wrong,
            /// that means the file does not exist.
            do {
                try FileManager.default.removeItem(at: data.localURL)
            } catch {
                
                print(#function, "Fail to remove. <\(error.localizedDescription)>")
                completion(false)
                return
            }
            /// remove the record from database
            /// CoreDataManager fetch record item by data.recordDate
            guard CoreDataManager.default.remove(data: data) else {
                
                print(self, #function, "CoreDataManager can not remove data <\(data)>")
                completion(false)
                return
            }
            /// remove from memory;
            self.datas.remove(at: index)
            
            completion(true)
        }
        
        dispatchOnQueue(execute: workitem)
    }
}
