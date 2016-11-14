//
//  DelegateProxy.swift
//  DelegateProxy
//
//  Created by Ryo Aoyama on 8/8/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

open class DelegateProxy: DPDelegateProxy {
    fileprivate static var classSelectors = [NSValue: Set<Selector>]()
    
    fileprivate var mutex = pthread_mutex_t()
    
    fileprivate var receivables = [Selector: Receivable]()
    
    public required override init() {
        super.init()
        let result = pthread_mutex_init(&mutex, nil)
        precondition(result == 0, "Failed to initialize mutex on \(self): \(result).")
    }
    
    deinit {
        let result = pthread_mutex_destroy(&mutex)
        precondition(result == 0, "Failed to destroy mutex on \(self): \(result).")
    }
}

public extension DelegateProxy {
    final override class func initialize() {
        lock()
        defer { unlock() }
        
        func collectSelectors(fromClass cls: AnyClass) -> Set<Selector> {
            var protocolsCount: UInt32 = 0
            guard let protocolPointer = class_copyProtocolList(cls, &protocolsCount) else { return .init() }
            
            let selectors = self.collectSelectors(fromProtocolPointer: protocolPointer, count: Int(protocolsCount))
            
            guard let supercls = class_getSuperclass(cls) else { return selectors }
            return selectors.union(collectSelectors(fromClass: supercls))
        }
        
        let selectors = collectSelectors(fromClass: self)
        
        if !selectors.isEmpty {
            classSelectors[classValue()] = selectors
        }
    }
    
    final override func interceptedSelector(_ selector: Selector, arguments: [Any]) {
        lock()
        defer { unlock() }
        
        receivables[selector]?.send(arguments: .init(arguments))
    }
    
    final override func responds(to aSelector: Selector!) -> Bool {
        return super.responds(to: aSelector) || canResponds(to: aSelector)
    }
    
    final func receive(_ selector: Selector, receiver: Receivable) {
        receive(selectors: [selector], receiver: receiver)
    }
    
    final func receive(_ selector: Selector, handler: @escaping (Arguments) -> Void) {
        receive(selectors: [selector], receiver: Receiver(handler))
    }
    
    final func receive(selectors: [Selector], receiver: Receivable) {
        selectors.forEach {
            precondition(responds(to: $0), "\(type(of: self)) doesn't respond to selector \($0).")
            receivables[$0] = receiver
        }
    }
    
    final func receive(selectors: [Selector], handler: @escaping (Arguments) -> Void) {
        receive(selectors: selectors, receiver: Receiver(handler))
    }
}

private extension DelegateProxy {
    static func classValue() -> NSValue {
        return .init(nonretainedObject: self)
    }
    
    static func collectSelectors(fromProtocol p: Protocol) -> Set<Selector> {
        var protocolMethodCount: UInt32 = 0
        let methodDescriptions = protocol_copyMethodDescriptionList(p, false, true, &protocolMethodCount)
        defer { free(methodDescriptions) }
        
        var protocolsCount: UInt32 = 0
        let protocols = protocol_copyProtocolList(p, &protocolsCount)
        
        let methodSelectors = (0..<protocolMethodCount)
            .flatMap { methodDescriptions?[Int($0)] }
            .filter(DP_isMethodReturnTypeVoid)
            .flatMap { $0.name }
        
        let protocolSelectors = protocols.map { collectSelectors(fromProtocolPointer: $0, count: Int(protocolsCount)) } ?? []
        
        return Set(methodSelectors).union(protocolSelectors)
    }
    
    static func collectSelectors(fromProtocolPointer protocolPointer: AutoreleasingUnsafeMutablePointer<Protocol?>, count: Int) -> Set<Selector> {
        return (0..<count)
            .flatMap { protocolPointer[$0] }
            .map(collectSelectors)
            .reduce(Set<Selector>()) { $0.union($1) }
    }
    
    func canResponds(to aSelector: Selector) -> Bool {
        lock()
        defer { unlock() }
        
        let allowedSelectors = type(of: self).classSelectors[type(of: self).classValue()]
        return allowedSelectors?.contains(aSelector) ?? false
    }
    
    static func lock() {
        let result = objc_sync_enter(self)
        precondition(result == 0, "Failed to lock \(self): \(result).")
    }
    
    static func unlock() {
        let result = objc_sync_exit(self)
        precondition(result == 0, "Failed to unlock \(self): \(result).")
    }
    
    func lock() {
        let result = pthread_mutex_lock(&mutex)
        precondition(result == 0, "Failed to lock \(self): \(result).")
    }
    
    func unlock() {
        let result = pthread_mutex_unlock(&mutex)
        precondition(result == 0, "Failed to unlock \(self): \(result).")
    }
}
