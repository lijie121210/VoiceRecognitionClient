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
    
    
    /// 测试appendingPathComponent能够自动区别最后的/

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
    
    
    /// 测试MeasurementType通过“\（MeasurementType.xxx）”强制全换能够得到正确的字符串
    /// 
    /// 这两个测试结果说明，不能随便重写description属性；这两个转换能成功就是因为description的默认值。
    
    func testMeasurementType() {
        
        let t = MeasurementType.airTemperature
        
        XCTAssertEqual(t.icon, "airTemperature")
        XCTAssertNotEqual(t.icon, "1")
        XCTAssertNotEqual(t.icon, "0")

    }
    
    func testAccessoryType() {
        
        let t = AccessoryType.fillLight
        
        XCTAssertEqual(t.icon, "fillLight")
        XCTAssertNotEqual(t.icon, "1")
        XCTAssertNotEqual(t.icon, "0")
    }
    
    
    /// 测试数组的替换方法
    
    func testArrayReplace() {
        
        var arr = [0,1,2,3,4,5]
        
        arr.replaceSubrange((1..<2), with: [6])
        
        XCTAssertEqual(arr[1], 6)
        
        arr.replaceSubrange((3..<4), with: [7])
        
        XCTAssertEqual(arr[3], 7)
        
        
    }
    
}
