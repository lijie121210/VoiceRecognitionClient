//
//  VGClientTests.swift
//  VGClientTests
//
//  Created by jie on 2017/2/11.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import XCTest
@testable import VGClient

class VGClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testPath() {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        let path = "home/jie/desktop"
        
        let path1 = path.appending("/test.jpg")
        let path2 = (path as NSString).appendingPathComponent("test.jpg")
        
        let url1 = URL(fileURLWithPath: path1)
        let url2 = URL(fileURLWithPath: path2)
        
        print(documentDirectory)
        print(path1)
        print(path2)
        print(url1)
        print(url2)
    }
    
    func testTimeInterval() {
        
        let t1: TimeInterval = 23
        let t2: TimeInterval = 60
        let t3: TimeInterval = 1023
        let t4: TimeInterval = 60 * 60
        let t5: TimeInterval = 3.5 * 60 * 60
        let t6: TimeInterval = 24 * 60 * 60
        let t7: TimeInterval = 4.3 * 24 * 60 * 60
        let t8: TimeInterval = 76 * 24 * 60 * 60
        let t9: TimeInterval = 0
        let t10: TimeInterval = -7263

        
        print(t1.dateDescription())
        print(t2.dateDescription())
        print(t3.dateDescription())
        print(t4.dateDescription())
        print(t5.dateDescription())
        print(t6.dateDescription())
        print(t7.dateDescription())
        print(t8.dateDescription())
        print(t9.dateDescription())
        print(t10.dateDescription())

        /*
         
        00:00:23
        00:01:00
        00:17:03
        01:00:00
        03:30:00
        01天 00:00:00
        04天 07:11:59
        76天 00:00:00
        00:00:00
        --:--
         
         */
    }
}
