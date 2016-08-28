//
//  DelegateProxyType.swift
//  DelegateProxy
//
//  Created by Ryo Aoyama on 8/20/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

private var associatedKey: UInt8 = 0

public protocol DelegateProxyType: class {
    associatedtype Owner: AnyObject
    
    func resetDelegateProxy(owner: Owner)
}

public extension DelegateProxyType where Self: DelegateProxy {
    static func proxyFor(_ owner: Owner) -> Self {
        let delegateProxy: Self
        if let associated = associatedProxyFor(owner) {
            delegateProxy = associated
        } else {
            delegateProxy = .init()
            objc_setAssociatedObject(owner, &associatedKey, delegateProxy, .OBJC_ASSOCIATION_RETAIN)
        }
        
        delegateProxy.resetDelegateProxy(owner: owner)
        
        return delegateProxy
    }
    
    private static func associatedProxyFor(_ owner: Owner) -> Self? {
        guard let object = objc_getAssociatedObject(owner, &associatedKey) else { return nil }
        if let proxy = object as? Self { return proxy }
        fatalError("Invalid associated object. Expected type is \(Self.self).")
    }
}
