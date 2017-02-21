//
//  DispatchQueueTests.swift
//  VGClient
//
//  Created by jie on 2017/2/21.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import XCTest
@testable import VGClient

class HaveQueue/*: NSObject */{
    let queue = DispatchQueue(label: "com.test.queue.serial")
    let key = DispatchSpecificKey<String>()
    
    var apples = 3
    
    deinit {
        print(self, #function, apples)
    }
    
    /*override */init() {
//        super.init()
        
        queue.setSpecific(key: key, value: "com.test.queue.key")
    }
    
    
    
    func useSelfInABlock() {
        
        queue.async {
            self.apples = 5
        }
    }
    
    func useSelfInWorkItem() {
        
        let item = DispatchWorkItem {
            var apps = 0
            for i in 0...10000000 {
                apps = i
            }
            self.apples = apps
            print(self, #function, "1")
        }
        item.perform()
        print(self, #function, "2")

    }
    
    func useSelfInWorkItemQeue() {
        
        let item = DispatchWorkItem {

            var apps = 0
            for i in 0...10000000 {
                apps = i
            }
            self.apples = apps
            
            print(self, #function, "1")

        }
        if let _ = DispatchQueue.getSpecific(key: key) {
            item.perform()
        } else {
            queue.async(execute: item)
        }
        print(self, #function, "2")
        
    }
    
    func useSelfInWorkItemQeue2() {
        
        queue.async {
            self.useSelfInWorkItemQeue()
        }
    }

}

class DispatchQueueTests: XCTestCase {
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
    
    func testWillRelease() {
        
        func method() {
            let ha = HaveQueue()
            ha.useSelfInABlock()
        }
        method()
        
        sleep(5)
    }
    
    func testWorkItem() {
        
        func method() {
            let ha = HaveQueue()
            ha.useSelfInWorkItem()
        }
        method()
        
        sleep(5)
    }
    
    func testWorkItem2() {
        
        func method() {
            let ha = HaveQueue()
            ha.useSelfInWorkItemQeue2()
        }
        method()
        
        sleep(5)
    }
}
