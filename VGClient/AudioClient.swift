//
//  AudioUploader.swift
//  VGClient
//
//  Created by jie on 2017/2/13.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit
import CocoaAsyncSocket


public struct SerializedData: Equatable {
    
    public enum DType: String, Equatable {
        case heartbeat = "heartbeat"
        case image = "image"
        case text = "text"
        case audio = "wav"
    }
    
    public struct DKey {
        static let type = "type"
        static let size = "size"
    }
    
    /// When packing data, it is package data; when unpacking data, it is original data.
    let data: Data
    let json: [String : String]
    let type: DType
    /// size of payloads, not including header
    let size: Int
    
    init?(unpack data: Data) {
        guard
            let res = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
            let d = res as? [String:String],
            let t = d[DKey.type],
            let s = d[DKey.size],
            let type = DType(rawValue: t),
            let size = Int(s)
            else {
                return nil
        }
        
        self.json = d
        self.type = type
        self.size = size
        self.data = data
    }
    
    init(pack data: Data = Data(), type: DType = .heartbeat) {
        
        var package = [String:String]()
        package[DKey.type] = type.rawValue
        package[DKey.size] = type == DType.heartbeat ? String(0) : String(data.count)
        
        /// Create the header data from dictionary and append end mark.
        var packagedata = try! JSONSerialization.data(withJSONObject: package, options: .prettyPrinted)
        packagedata.append(GCDAsyncSocket.crlfData())
        
        /// Append real data. So heartbeat data should be Data().
        packagedata.append(data)
        
        self.json = package
        self.type = type
        self.size = data.count
        self.data = packagedata
    }
    
}

public func ==(lhs: SerializedData, rhs: SerializedData) -> Bool {
    return lhs.json == rhs.json && lhs.type == rhs.type && lhs.size == rhs.size && lhs.data == rhs.data
}


fileprivate let AudioServerHost: String = "10.164.54.125"
fileprivate let AudioServerPort: UInt16 = 9632

public typealias AudioClientCompletionHandler = (Bool) -> ()
public typealias AudioClientProgressHandler = (Float) -> ()

public class AudioClient: NSObject, GCDAsyncSocketDelegate {
    
    public struct Tag {
        static let heartbeat = 1
        static let data = 2
    }
    
    fileprivate var socket: GCDAsyncSocket!
    fileprivate var heartbeatTimer: DispatchSourceTimer?
    fileprivate var writingCompletionHandler: AudioClientCompletionHandler?
    fileprivate var writingProgressionHandler: AudioClientProgressHandler?
    fileprivate var writingSerializedData: SerializedData?
    
    deinit {
        socket.disconnect()
        
        socket.delegate = nil
        
        socket = nil
        
        writingSerializedData = nil
        
        writingCompletionHandler = nil
        
        writingProgressionHandler = nil
        
        heartbeatTimer?.cancel()
        
        heartbeatTimer = nil
    }
    
    public override init() {
        super.init()
        
        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue(label: "com.vg.client.\(Date().timeIntervalSince1970)"))
    }
    
    /// Heartbeat timer
    fileprivate func beginHeartbeatTimer() {
        
        let heartbeatQueue = DispatchQueue(label: "com.vg.client.heartbeat.\(Date().timeIntervalSince1970)", attributes: .concurrent)

        let event = DispatchWorkItem { [weak self] in if let s = self {
            
            let serializedData = SerializedData(pack: Data(), type: .heartbeat)
            s.socket.write(serializedData.data, withTimeout: -1, tag: Tag.heartbeat)
        }}
        
        let timer = DispatchSource.makeTimerSource(queue: heartbeatQueue)
        timer.scheduleRepeating(deadline: .now(), interval: .seconds(60), leeway: .seconds(5))
        timer.setEventHandler(handler: event)
        timer.resume()
        
        heartbeatTimer?.cancel()
        heartbeatTimer = timer
    }
    
    fileprivate func endHeartbeatTimer() {
        heartbeatTimer?.cancel()
        heartbeatTimer = nil
    }
    
    /// Socket stack
    
    public var isConnected: Bool {
        return socket.isConnected
    }
    
    public func connect() {
        guard !socket.isConnected else {
            print(self, #function,"already connecting to ", socket.connectedHost ?? "unknown host.")
            return
        }
        do {
            try socket.connect(toHost: AudioServerHost, onPort: AudioServerPort, withTimeout: 60)
        } catch {
            print(self, #function, "fail to connect to ", AudioServerHost, ":", AudioServerPort, " .", error.localizedDescription)
        }
    }
    
    public func disconnect() {
        socket.disconnect()
    }
    
    /// Write data
    
    /// The progression and completion handler default is nil
    public func write(data: Data, type: SerializedData.DType, progression: AudioClientProgressHandler? = nil, completion: AudioClientCompletionHandler? = nil) {
        
        let serializedData = SerializedData(pack: data, type: type)

        writingProgressionHandler = progression

        writingCompletionHandler = completion
        
        writingSerializedData = serializedData
        
        socket.write(serializedData.data, withTimeout: -1, tag: Tag.data)
    }
    
    /// GCDAsyncSocket delegate
    
    public func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        
        guard tag == Tag.data, let completion = writingCompletionHandler else {
            return
        }
        
        completion(true)
        
        writingSerializedData = nil
        
        writingCompletionHandler = nil
        
        writingProgressionHandler = nil
    }
    
    public func socket(_ sock: GCDAsyncSocket, didWritePartialDataOfLength partialLength: UInt, tag: Int) {
        
        guard
            tag == Tag.data,
            let progression = writingProgressionHandler,
            let writingdata = writingSerializedData else {
                return
        }
        let size = writingdata.data.count
        let progress = Float(partialLength) / Float(size)
        
        print(progress)
        
        progression(progress)
    }
    
    public func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        
        /// Begin heartbeat timer
        beginHeartbeatTimer()
    }
    
    public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print(self, #function, err?.localizedDescription ?? "unkunown error.")
        
        /// Unsure where to put writing failure code
        if let completion = writingCompletionHandler {
            completion(false)
        }
        
        /// End hearbeat timer
        endHeartbeatTimer()
    }
}
