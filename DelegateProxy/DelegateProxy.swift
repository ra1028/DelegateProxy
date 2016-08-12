//
//  DelegateProxy.swift
//  DelegateProxy
//
//  Created by Ryo Aoyama on 8/8/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

public class DelegateProxy: DPDelegateProxy {
    private static var selectorsOfClass = [NSValue: Set<Selector>]()
    
    private static var classValue: NSValue {
        return .init(nonretainedObject: self)
    }
    
    private var receivableOfSelector = [Selector: Receivable]()
}

public extension DelegateProxy {
    final override class func initialize() {
        lock()
        defer { unlock() }
        
        var selectors = Set<Selector>()
        var targetClass: AnyClass? = self
        
        while let target = targetClass {
            var protocolsCount: UInt32 = 0
            let protocols = class_copyProtocolList(target, &protocolsCount)
            
            (0..<protocolsCount).forEach {
                guard let selectorsForProtocol = protocols[Int($0)].map(collectSelectors) else { return }
                selectors.unionInPlace(selectorsForProtocol)
            }
            
            targetClass = class_getSuperclass(target)
        }
        
        if !selectors.isEmpty {
            selectorsOfClass[classValue] = selectors
        }
    }
    
    final override func interceptedSelector(selector: Selector, arguments: [AnyObject]) {
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
    static func collectSelectors(p: Protocol) -> Set<Selector> {
        var selectors = Set<Selector>()
        
        var protocolMethodCount: UInt32 = 0
        let methodDescriptions = protocol_copyMethodDescriptionList(p, false, true, &protocolMethodCount)
        
        (0..<protocolMethodCount).forEach {
            let methodDescription = methodDescriptions[Int($0)]
            if DP_isMethodReturnTypeVoid(methodDescription) {
                selectors.insert(methodDescription.name)
            }
        }
        
        free(methodDescriptions)
        
        var protocolsCount: UInt32 = 0
        let protocols = protocol_copyProtocolList(p, &protocolsCount)
        
        (0..<protocolsCount).forEach {
            guard let selectorsForProtocol = protocols[Int($0)].map(collectSelectors) else { return }
            selectors.unionInPlace(selectorsForProtocol)
        }
        
        return selectors
    }
    
    func canRespondToSelector(selector: Selector) -> Bool {
        lock()
        defer { unlock() }
        
        let allowedSelectors = self.dynamicType.selectorsOfClass[self.dynamicType.classValue]
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
        let result = objc_sync_enter(self)
        assert(result == 0, "Failed to lock \(self): \(result).")
    }
    
    func unlock() {
        let result = objc_sync_exit(self)
        assert(result == 0, "Failed to unlock \(self): \(result).")
    }
}