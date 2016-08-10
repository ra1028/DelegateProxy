//
//  DelegateForwardable.swift
//  DelegateProxy
//
//  Created by Ryo Aoyama on 8/10/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

private var key: UInt8 = 0

public protocol DelegateForwardable: class {
    associatedtype Proxy: DelegateProxy
    
    static func createDelegateProxy() -> Proxy
    func setDelegateProxy(proxy: Proxy)
}

public extension DelegateForwardable {
    var delegateProxy: Proxy {
        let object: AnyObject? = objc_getAssociatedObject(self, &key)
        
        if let proxy = object as? Proxy {
            setDelegateProxy(proxy)
            return proxy
        }
        
        let proxy = Self.createDelegateProxy()
        objc_setAssociatedObject(self, &key, proxy, .OBJC_ASSOCIATION_RETAIN)
        setDelegateProxy(proxy)
        return proxy
    }
}