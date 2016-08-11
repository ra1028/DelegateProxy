//
//  DelegateForwardable.swift
//  DelegateProxy
//
//  Created by Ryo Aoyama on 8/10/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

private var associatedKey: UInt8 = 0

public protocol DelegateForwardable: class {
    associatedtype DelegateProxyType: DelegateProxy
    
    static func createDelegateProxy() -> DelegateProxyType
    func setDelegateProxy(delegateProxy: DelegateProxyType)
}

public extension DelegateForwardable {
    var delegateProxy: DelegateProxyType {
        let object: AnyObject? = objc_getAssociatedObject(self, &associatedKey)
        
        if let proxy = object as? DelegateProxyType {
            setDelegateProxy(proxy)
            return proxy
        }
        
        let proxy = Self.createDelegateProxy()
        objc_setAssociatedObject(self, &associatedKey, proxy, .OBJC_ASSOCIATION_RETAIN)
        setDelegateProxy(proxy)
        return proxy
    }
}