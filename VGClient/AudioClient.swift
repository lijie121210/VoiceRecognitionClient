//
//  AudioUploader.swift
//  VGClient
//
//  Created by jie on 2017/2/13.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

public func ==(lhs: SerializedData, rhs: SerializedData) -> Bool {
    return lhs.json == rhs.json && lhs.type == rhs.type && lhs.size == rhs.size && lhs.data == rhs.data
}
public func ==(lhs: Response, rhs: Response) -> Bool {
    return lhs.data == rhs.data && lhs.json == rhs.json && lhs.message == rhs.message && lhs.state == rhs.state
}

public struct SerializedData: Equatable {
    
    public enum DType: String, Equatable {
        case heartbeat = "hea"
        case image = "img"
        case text = "txt"
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
        package[DKey.size] = String(format: "%019d", type == DType.heartbeat ? 0 : data.count)
        
        /// Create the header data from dictionary and append end mark.
        var packagedata = try! JSONSerialization.data(withJSONObject: package, options: .prettyPrinted)
        
        print(#function, packagedata.count)

        packagedata.append(GCDAsyncSocket.crlfData())
        
        print(#function, packagedata.count)
        
        /// Append real data. So heartbeat data should be Data().
        packagedata.append(data)
        
        self.json = package
        self.type = type
        self.size = data.count
        self.data = packagedata
    }
    
    func string(from integer: Int) -> String {
        let str = String(integer)
        let len = str.lengthOfBytes(using: .utf8)
        let max = String(Int.max).lengthOfBytes(using: .utf8)
        var format = String(repeating: "0", count: max)
        let startIndex = format.index(format.endIndex, offsetBy: 0 - len)
        format.replaceSubrange(startIndex..<format.endIndex, with: str)
        return format
    }
}


public struct Response: Equatable {
    
    struct Key {
        static let state = "state"
        static let message = "message"
        static let data = "data"
    }
    
    enum State: Int {
        case fail
        case success
    }
    
    let json: [String : String]
    let state: State
    let data: String
    let message: String
    
    init?(response: Data) {
        guard
            let res = try? JSONSerialization.jsonObject(with: response, options: .mutableContainers),
            let d = res as? [String:String],
            let s = d[Key.state],
            let sraw = Int(s),
            let state = State(rawValue: sraw),
            let message = d[Key.message],
            let data = d[Key.data] else {
                return nil
        }
        self.json = d
        self.state = state
        self.data = data
        self.message = message
    }
}

public typealias AudioClientCompletionHandler = (Bool) -> ()
public typealias AudioClientProgressHandler = (Float) -> ()
public typealias AudioClientRecognitionHandler = (String?) -> ()

public class AudioClient: NSObject, GCDAsyncSocketDelegate {
    
    public struct Server {
        static let host = "10.164.49.15"
        static let port: UInt16 = 9634
    }
    
    public struct Tag {
        static let heartbeat = 1
        static let data = 2
        static let response = 3
    }
    
    fileprivate var socket: GCDAsyncSocket!
    
    /// 回调函数
    fileprivate var heartbeatTimer: DispatchSourceTimer?
    fileprivate var writingCompletionHandler: AudioClientCompletionHandler?
    fileprivate var writingProgressionHandler: AudioClientProgressHandler?
    fileprivate var speechRecognitionHandler: AudioClientRecognitionHandler?

    /// 当前正在发送的数据包
    fileprivate var writingSerializedData: SerializedData?

    deinit {
        clear()
    }
    
    public override init() {
        super.init()
        
        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue(label: "com.vg.client.\(Date().timeIntervalSince1970)"))
    }
    
    public func clear() {
        
        if socket.isConnected {
            socket.disconnect()
        }
        
        socket.delegate = nil
        
        socket = nil
        
        writingSerializedData = nil
        
        writingCompletionHandler = nil
        
        writingProgressionHandler = nil
        
        speechRecognitionHandler = nil
        
        heartbeatTimer?.cancel()
        
        heartbeatTimer = nil
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
    
    /// Socket connection
    
    public var isConnected: Bool {
        return socket.isConnected
    }
    
    public func connect() {
        guard !socket.isConnected else {
            print(self, #function,"already connecting to ", socket.connectedHost ?? "unknown host.")
            return
        }
        do {
            try socket.connect(toHost: Server.host, onPort: Server.port, withTimeout: 60)
        } catch {
            print(self, #function, "fail to connect .", error.localizedDescription)
        }
    }
    
    public func disconnect() {
        socket.disconnect()
    }
    
    /// GCDAsyncSocket delegate
    
    public func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        
        /// Begin heartbeat timer
//        beginHeartbeatTimer()
        
        if let data = writingSerializedData?.data {
            socket.write(data, withTimeout: -1, tag: Tag.data)
        }
    }
    
    public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print(self, #function, err?.localizedDescription ?? "unkunown error.")
        
        /// Unsure where to put writing failure code
        if let completion = writingCompletionHandler {
            completion(false)
        }
//        
        if
            let recognition = speechRecognitionHandler ,
            let reason = err?.localizedDescription,
            reason.contains("Socket closed by remote peer") {
            
            recognition(nil)
        }
        
        /// End hearbeat timer
//        endHeartbeatTimer()
        
    }
    
    /// Write data
    
    /// The progression and completion handler default is nil
    public func write(data: Data, type: SerializedData.DType, progression: AudioClientProgressHandler? = nil, completion: AudioClientCompletionHandler? = nil, recognition: AudioClientRecognitionHandler?) {
        
        let serializedData = SerializedData(pack: data, type: type)

        writingProgressionHandler = progression

        writingCompletionHandler = completion
        
        speechRecognitionHandler = recognition
        
        writingSerializedData = serializedData
        
        if !socket.isConnected {
            connect()
        } else {
            socket.write(serializedData.data, withTimeout: -1, tag: Tag.data)
        }
        
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

        /// 开始等待处理结果
        socket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: Tag.response)

    }
    
    public func socket(_ sock: GCDAsyncSocket, didWritePartialDataOfLength partialLength: UInt, tag: Int) {
        
        guard
            tag == Tag.data,
            let progression = writingProgressionHandler,
            let writingdata = writingSerializedData else {
                return
        }
        let progress = Float(partialLength) / Float(writingdata.data.count)
        
        print(progress)
        
        progression(progress)
    }
    
    /// Read data
    
    public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        
        guard tag == Tag.response, let recognition = speechRecognitionHandler else {
            return
        }
        
        guard let response = Response(response: data), response.state == .success else {
            
            recognition(nil)
            
            return
        }

        recognition(response.data)
        
        speechRecognitionHandler = nil
    }
    
}
