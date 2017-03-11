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
    

    
}
