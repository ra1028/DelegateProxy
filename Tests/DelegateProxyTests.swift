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
            guard let arg: Int = $0.value(at: 0) else {
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
            guard let arg: Int = $0.value(at: 0) else {
                XCTAssert(false, "Invalid argument type")
                return
            }
            int += arg
        }
        
        var bool = false
        proxy.receive(#selector(TestInheritedDelegate.boolEvent(_:))) {
            guard let arg: Bool = $0.value(at: 0) else {
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
    
    func testCanNotReceiveImplementedMethod() {
        let proxy = DelegateImplementedProxy()
        let tester = DelegateTester()
        tester.delegate = proxy
        
        var value = 0
        proxy.receive(#selector(TestDelegate.intEvent(_:))) {
            guard let arg: Int = $0.value(at: 0) else {
                XCTAssert(false, "Invalid argument type")
                return
            }
            value += arg
        }
        
        tester.sendIntEvent(1)
        XCTAssertEqual(value, 0)
        XCTAssertEqual(proxy.receivedValues, [1])
    }
    
    func testConcurrentThreadDelegate() {
        let proxy = TestDelegateProxy()
        let tester = DelegateTester()
        tester.delegate = proxy
        
        var value = 0
        proxy.receive(#selector(TestDelegate.intEvent(_:))) {
            guard let arg: Int = $0.value(at: 0) else {
                XCTAssert(false, "Invalid argument type")
                return
            }
            value += arg
        }
        
        let exp = expectation(description: "Receive delegate event in concurrent thread")
        let group = DispatchGroup()
        
        let repeatTimes = 100
        
        (0..<repeatTimes).forEach {
            let queue = DispatchQueue(label: "queue\($0)", attributes: .concurrent)
            queue.async(group: group) { tester.sendIntEvent(1) }
        }
        
        group.notify(queue: .main, execute: exp.fulfill)
        
        waitForExpectations(timeout: 1) { XCTAssertNil($0) }
        
        XCTAssertEqual(value, repeatTimes)
    }
}
