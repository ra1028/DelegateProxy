//
//  DelegateProxyTests.swift
//  DelegateProxyTests
//
//  Created by Ryo Aoyama on 8/13/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import XCTest
import DelegateProxy

final class DelegateProxyTests: XCTestCase {
    func testDelegate() {
        let proxy = TestDelegateProxy()
        let tester = DelegateTester()
        tester.delegate = proxy
        
        var value = 0
        proxy.receive(#selector(TestDelegate.intEvent(_:))) {
            guard let arg: Int = $0.value(0) else {
                XCTAssert(false, "Invalid argument type")
                return
            }
            value += arg
        }
        
        tester.sendIntEvent(1)
        XCTAssertEqual(value, 1)
        
        tester.sendIntEvent(4)
        XCTAssertEqual(value, 5)
    }
    
    func testinheritedDelegate() {
        let proxy = TestInheritedDelegateProxy()
        let tester = InheritedDelegateTester()
        tester.delegate = proxy
        
        var int = 0
        proxy.receive(#selector(TestInheritedDelegate.intEvent(_:))) {
            guard let arg: Int = $0.value(0) else {
                XCTAssert(false, "Invalid argument type")
                return
            }
            int += arg
        }
        
        var bool = false
        proxy.receive(#selector(TestInheritedDelegate.boolEvent(_:))) {
            guard let arg: Bool = $0.value(0) else {
                XCTAssert(false, "Invalid argument type")
                return
            }
            bool = arg
        }
        
        tester.sendIntEvent(5)
        XCTAssertEqual(int, 5)
        
        tester.sendBoolEvent(true)
        XCTAssertEqual(bool, true)
    }
    
    func testConcurrentThreadDelegate() {
        let proxy = TestDelegateProxy()
        let tester = DelegateTester()
        tester.delegate = proxy
        
        var value = 0
        proxy.receive(#selector(TestDelegate.intEvent(_:))) {
            guard let arg: Int = $0.value(0) else {
                XCTAssert(false, "Invalid argument type")
                return
            }
            value += arg
        }
        
        let expectation = expectationWithDescription("Value update 100 times in concurrent thread")
        let group = dispatch_group_create()
        
        (0..<100).forEach {
            let queue = dispatch_queue_create("queue\($0)", DISPATCH_QUEUE_CONCURRENT)
            dispatch_group_async(group, queue) { tester.sendIntEvent(1) }
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), expectation.fulfill)
        
        waitForExpectationsWithTimeout(15) { _ in XCTAssertEqual(value, 100) }
    }
}
