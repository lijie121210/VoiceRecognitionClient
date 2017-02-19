//
//  AudioPlayer.swift
//  VGClient
//
//  Created by jie on 2017/2/19.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import AVFoundation

class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    
    static let sharedPlayer: AudioPlayer = AudioPlayer()
    
    var player: AVAudioPlayer!
    
    private var completionHandler: ( (AudioPlayer, Bool) -> () )? = nil
    
    private override init() {
        super.init()
    }
    
    func startPlaying(url: URL, completion: ( (AudioPlayer, Bool) -> () )? = nil) {
        
        if (player != nil && player.isPlaying) {
            stopPlaying()
        }
        if !FileManager.default.fileExists(atPath: url.path) {
            
            completion?(self, false)
            
            print("AudioPlayer: file not exists")
            
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategorySoloAmbient)
            
            player = try AVAudioPlayer(contentsOf: url)
            
        } catch {
            
            completion?(self, false)
            
            print("AudioPlayer: initilization error or set session category")
            return
        }
        
        completionHandler = completion
        
        player.delegate = self
        player.play()
    }
    
    /// This method will not trigger audioPlayerDidFinishPlaying(_:, _:)
    func stopPlaying() {
        if let p = player {
            p.stop()
            p.delegate = nil
        }
        player = nil
        completionHandler = nil
    }
    
    /// AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("audioPlayerDidFinishPlaying flag:", flag)
        
        defer {
            completionHandler = nil
        }
        
        guard let handler = completionHandler else {
            return
        }
        
        DispatchQueue.main.async {
            handler(self, flag)
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
        guard let e = error else {
            return
        }
        print("audioRecorderEncodeErrorDidOccur, ", e.localizedDescription)
    }
}
