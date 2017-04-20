//
//  AudioRecognizer.swift
//  VGClient
//
//  Created by viwii on 2017/4/17.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit
import Speech

@available(iOS 10.0, *)
class AudioRecognizer: NSObject {

    var recognizer = SFSpeechRecognizer()
    
    var request: SFSpeechRecognitionRequest?
    
    var url: URL?
    
    var result: SFSpeechRecognitionResult?
    
    var isAvailable: Bool {
        if let reg = recognizer {
            return reg.isAvailable
        }
        return false
    }
    
    deinit {
        print(self, #function)
    }
    
    override init() {
        super.init()
    }
    
    init(url: URL) {
        super.init()
        self.url = url
        self.request = SFSpeechURLRecognitionRequest(url: url)
    }
    
    func recognize(progression: ((String?) -> ())? = nil, completion: @escaping (String?, SFSpeechRecognitionResult?) -> Void) {
        guard let reg = recognizer, let request = request else {
            return completion(nil, nil)
        }
        reg.recognitionTask(with: request) { [weak self] (res, err) in
            if let _ = err {
                completion(nil, nil)
                return
            }
            guard let res = res else {
                completion(nil, nil)
                return 
            }
            self?.result = res
            if res.isFinal {
                completion(res.bestTranscription.formattedString, res)
                
                print(res.bestTranscription.formattedString)
                print(res.bestTranscription.segments)
                
            } else {
                progression?(res.bestTranscription.formattedString)
            }
        }
    }
    
    func recognizeHMM(speech: URL, completion: @escaping (String?, SFSpeechRecognitionResult?) -> Void) {
    
    }
}
