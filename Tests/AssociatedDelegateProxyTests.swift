//
//  AssociatedDelegateProxyTests.swift
//  DelegateProxy
//
//  Created by Ryo Aoyama on 8/13/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import XCTest
import DelegateProxy

final class AssociatedDelegateProxyTests: XCTestCase {
    func testAssociatedProxy() {
        let tester = DelegateTester()
        let proxy1 = tester.delegateProxy
        let proxy2 = tester.delegateProxy
        
        XCTAssertEqual(proxy1, proxy2)
    }
    
    func testDelegateForwardable() {
        let tester = DelegateTester()
        
        var value = 0
        tester.delegateProxy
            .receive(#selector(TestDelegate.intEvent(_:))) {
                guard let arg: Int = $0.value(0) else {
                    XCTAssert(false, "Invalid argument type")
                    return
                }
                value += arg
        }
        
        tester.sendIntEvent(10)
        XCTAssertEqual(value, 10)
        
        tester.sendIntEvent(5)
        XCTAssertEqual(value, 15)
    }
}