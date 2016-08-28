//
//  DelegateTester.swift
//  DelegateProxy
//
//  Created by Ryo Aoyama on 8/13/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import DelegateProxy

@objc protocol TestDelegate {
    @objc optional func intEvent(_ value: Int)
}

@objc protocol TestInheritedDelegate: TestDelegate {
    @objc optional func boolEvent(_ value: Bool)
}

final class DelegateTester: NSObject {
    weak var delegate: TestDelegate?
    
    func sendIntEvent(_ value: Int) {
        delegate?.intEvent!(value)
    }
}

final class InheritedDelegateTester: NSObject {
    weak var delegate: TestInheritedDelegate?
    
    func sendIntEvent(_ value: Int) {
        delegate?.intEvent!(value)
    }
    
    func sendBoolEvent(_ value: Bool) {
        delegate?.boolEvent!(value)
    }
}

final class TestDelegateProxy: DelegateProxy, TestDelegate, DelegateProxyType {
    func resetDelegateProxy(owner: DelegateTester) {
        owner.delegate = self
    }
}
final class TestInheritedDelegateProxy: DelegateProxy, TestInheritedDelegate, DelegateProxyType {
    func resetDelegateProxy(owner: InheritedDelegateTester) {
        owner.delegate = self
    }
}
final class DelegateImplementedProxy: DelegateProxy, TestDelegate {
    private(set) var receivedValues = [Int]()
    
    func intEvent(_ value: Int) {
        receivedValues.append(value)
    }
}

extension DelegateTester {
    var delegateProxy: TestDelegateProxy {
        return .proxyFor(self)
    }
}
