//
//  DelegateProxy.swift
//  DelegateProxy
//
//  Created by Ryo Aoyama on 8/8/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

public class DelegateProxy: DPDelegateProxy {
    private static var selectorsOfClass = [NSValue: Set<Selector>]()
    
    private var mutex = pthread_mutex_t()
    
    private var receivableOfSelector = [Selector: Receivable]()
    
    public required override init() {
        super.init()
        let result = pthread_mutex_init(&mutex, nil)
        assert(result == 0, "Failed to initialize mutex on \(self): \(result).")
    }
    
    deinit {
        let result = pthread_mutex_destroy(&mutex)
        assert(result == 0, "Failed to destroy mutex on \(self): \(result).")
    }
}

public extension DelegateProxy {
    final override class func initialize() {
        lock()
        defer { unlock() }
        
        func selectorsForClass(cls: AnyClass) -> Set<Selector> {
            var protocolsCount: UInt32 = 0
            let protocols = class_copyProtocolList(cls, &protocolsCount)
            let selectors = selectorsForProtocols(protocols, count: Int(protocolsCount))
            
            guard let supercls = class_getSuperclass(cls) else { return selectors }
            return selectors.union(selectorsForClass(supercls))
        }
        
        let selectors = selectorsForClass(self)
        if !selectors.isEmpty {
            selectorsOfClass[classValue()] = selectors
        }
    }
    
    final override func interceptedSelector(selector: Selector, arguments: [AnyObject]) {
        lock()
        defer { unlock() }
        
        receivableOfSelector[selector]?.send(Arguments(arguments))
    }
    
    final override func respondsToSelector(aSelector: Selector) -> Bool {
        return super.respondsToSelector(aSelector) || canRespondToSelector(aSelector)
    }
    
    final func receive(selector: Selector..., receiver: Receivable) {
        receive(selectors: selector, receiver: receiver)
    }
    
    final func receive(selector: Selector..., handler: Arguments -> Void) {
        receive(selectors: selector, receiver: Receiver(handler))
    }
    
    final func receive(selectors selectors: [Selector], receiver: Receivable) {
        selectors.forEach {
            assert(respondsToSelector($0), "\(self.dynamicType) doesn't respond to selector \($0).")
            receivableOfSelector[$0] = receiver
        }
    }
    
    final func receive(selectors selectors: [Selector], handler: Arguments -> Void) {
        receive(selectors: selectors, receiver: Receiver(handler))
    }
}

private extension DelegateProxy {
    static func classValue() -> NSValue {
        return .init(nonretainedObject: self)
    }
    
    static func collectSelectors(p: Protocol) -> Set<Selector> {
        var protocolMethodCount: UInt32 = 0
        let methodDescriptions = protocol_copyMethodDescriptionList(p, false, true, &protocolMethodCount)
        defer { free(methodDescriptions) }
        
        var protocolsCount: UInt32 = 0
        let protocols = protocol_copyProtocolList(p, &protocolsCount)
        
        let methodSelectors = (0..<protocolMethodCount)
            .map { methodDescriptions[Int($0)] }
            .filter(DP_isMethodReturnTypeVoid)
            .map { $0.name }
        
        return selectorsForProtocols(protocols, count: Int(protocolsCount)).union(Set(methodSelectors))
    }
    
    static func selectorsForProtocols(protocols: AutoreleasingUnsafeMutablePointer<Protocol?>, count: Int) -> Set<Selector> {
        return (0..<count)
            .flatMap { protocols[$0] }
            .map(collectSelectors)
            .reduce(Set<Selector>()) { $0.union($1) }
    }
    
    func canRespondToSelector(selector: Selector) -> Bool {
        lock()
        defer { unlock() }
        
        let allowedSelectors = self.dynamicType.selectorsOfClass[self.dynamicType.classValue()]
        return allowedSelectors?.contains(selector) ?? false
    }
    
    static func lock() {
        let result = objc_sync_enter(self)
        assert(result == 0, "Failed to lock \(self): \(result).")
    }
    
    static func unlock() {
        let result = objc_sync_exit(self)
        assert(result == 0, "Failed to unlock \(self): \(result).")
    }
    
    func lock() {
        let result = pthread_mutex_lock(&mutex)
        assert(result == 0, "Failed to lock \(self): \(result).")
    }
    
    func unlock() {
        let result = pthread_mutex_unlock(&mutex)
        assert(result == 0, "Failed to unlock \(self): \(result).")
    }
}