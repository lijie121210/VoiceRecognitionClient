//
//  AudioOperatorTests.swift
//  VGClient
//
//  Created by jie on 2017/2/23.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import XCTest
@testable import VGClient

class AudioOwner: NSObject {
    
    var audioOperator: AudioOperator?
    
    deinit {
        print(self, #function)
    }
}

class AudioOperatorTests: XCTestCase {
    
    var audioOwner: AudioOwner!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        audioOwner = AudioOwner()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        audioOwner = nil
        
        sleep(5)
    }
    
    
    func testOperator() {
        
        audioOwner.audioOperator = AudioOperator(averagePowerReport: { (oper, power) in
            print(self, #function, power)
        }, timeIntervalReport: { (oper, time) in
            print(self, #function, time)
        }, completionHandler: { (oper, comp, data) in
            print(self, #function, comp, data ?? "nil value")
        }, failureHandler: { (oper, error) in
            print(self, #function, error?.localizedDescription ?? "nil error")
        })
        
        XCTAssertNotNil(audioOwner.audioOperator)
        
        audioOwner.audioOperator!.startRecording(filename: "test.wav", storageURL: FileManager.dataURL(with: "test.wav"))
        
        sleep(2)

        XCTAssertTrue(audioOwner.audioOperator!.isRecording)
        
        XCTAssertFalse(audioOwner.audioOperator!.isUpdatingTimerCancelled)
        
        audioOwner.audioOperator!.stopRecording()
        
        XCTAssertFalse(audioOwner.audioOperator!.isRecording)
        
        XCTAssertTrue(audioOwner.audioOperator!.isUpdatingTimerCancelled)
        
        audioOwner.audioOperator?.releaseResource()
        
        XCTAssertNil(audioOwner.audioOperator!.averagePowerReport)
        XCTAssertNil(audioOwner.audioOperator!.timeIntervalReport)
        XCTAssertNil(audioOwner.audioOperator!.completionHandler)
        XCTAssertNil(audioOwner.audioOperator!.failureHandler)
        
        audioOwner.audioOperator = nil
        
        XCTAssertNil(audioOwner.audioOperator)
    }
    
}
