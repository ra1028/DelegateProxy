//
//  DelegateProxyType.swift
//  DelegateProxy
//
//  Created by Ryo Aoyama on 8/20/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

private var associatedKey: UInt8 = 0

public protocol DelegateProxyType: class {
    associatedtype Owner
    
    func resetDelegateProxy(owner: Owner)
}

public extension DelegateProxyType where Self: DelegateProxy {
    static func proxy(for owner: Owner) -> Self {
        lock()
        defer { unlock() }
        
        let delegateProxy: Self
        if let associated = associatedProxy(for: owner) {
            delegateProxy = associated
        } else {
            delegateProxy = .init()
            objc_setAssociatedObject(owner, &associatedKey, delegateProxy, .OBJC_ASSOCIATION_RETAIN)
        }
        
        delegateProxy.resetDelegateProxy(owner: owner)
        
        return delegateProxy
    }
    
    private static func associatedProxy(for owner: Owner) -> Self? {
        guard let object = objc_getAssociatedObject(owner, &associatedKey) else { return nil }
        if let proxy = object as? Self { return proxy }
        fatalError("Invalid associated object. Expected type is \(Self.self).")
    }
    
    private static func lock() {
        let result = objc_sync_enter(self)
        precondition(result == 0, "Failed to lock \(self): \(result).")
    }
    
    private static func unlock() {
        let result = objc_sync_exit(self)
        precondition(result == 0, "Failed to unlock \(self): \(result).")
    }
}
