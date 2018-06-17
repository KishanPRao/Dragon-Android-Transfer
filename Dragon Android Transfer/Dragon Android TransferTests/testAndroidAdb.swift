//
//  testAndroidAdb.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 10/10/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import XCTest
//import Foundation
//@testable import Dragon_Android_Transfer

class testAndroidAdb: XCTestCase {
    let androidHandler = AndroidHandler()
    
    let expect = XCTestExpectation(description: "abc")
    
    class FileProgressDelegateImpl : FileProgressDelegate {
        let androidHandler: AndroidHandler
        let expect : XCTestExpectation
        
        init(_ handler: AndroidHandler, _ e: XCTestExpectation) {
            androidHandler = handler
            expect = e
        }
        
        func onStart(_ totalSize: Number, transferType: Int) {
            
        }
        
        func currentFile(_ fileName: String) {
            
        }
        
        func onProgress(_ progress: Int) {
            
        }
        
        func onCompletion(status: FileProgressStatus) {
            Swift.print("Done!")
            self.androidHandler.stop()
            self.expect.fulfill()
        }
    }
    var delegate : FileProgressDelegateImpl? = nil
    
    override func setUp() {
        super.setUp()
        delegate = FileProgressDelegateImpl(androidHandler, expect)
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let data = NSDataAsset.init(name: "adb")?.data
        androidHandler.initialize(data!)
        androidHandler.start()
        ThreadUtils.runInMainThreadAfter(delayMs: 5000, {
            let devices = self.androidHandler.getAndroidDevices()
            self.androidHandler.setActiveDevice(devices[0])
            self.LogV("Start")
//            androidHandler.start()
            let file = BaseFile(fileName: "Alarms", path: "/sdcard/", type: 0, size: 0)
            let src = [file]
            self.androidHandler.pull(src, destination: "/Users/kishanprao/Documents/", delegate: self.delegate!)
        })
        wait(for: [expect], timeout: 10000)
        LogI("Done")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
