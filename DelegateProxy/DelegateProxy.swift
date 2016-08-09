//
//  DelegateProxy.swift
//  DelegateProxy
//
//  Created by Ryo Aoyama on 8/8/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

public class DelegateProxy: DPDelegateProxy {
    private static var selectorsOfClass = [NSValue: Set<Selector>]()
    private var receivableOfSelector = [Selector: Receivable]()
}

public extension DelegateProxy {
    override class func initialize() {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
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
            let classValue = NSValue(nonretainedObject: self)
            selectorsOfClass[classValue] = selectors
        }
    }
    
    override func interceptedSelector(selector: Selector, arguments: [AnyObject]) {
        receivableOfSelector[selector]?.send(arguments)
    }
    
    func register(receiver: Receivable, selector: Selector...) {
        register(receiver, selectors: selector)
    }
    
    func receive(selector: Selector..., handler: [AnyObject] -> Void) {
        receive(selector, handler: handler)
    }
}

extension DelegateProxy {
    func register(receiver: Receivable, selectors: [Selector]) {
        selectors.forEach { receivableOfSelector[$0] = receiver }
    }
    
    func receive(selectors: [Selector], handler: [AnyObject] -> Void) {
        register(Receiver(handler), selectors: selectors)
    }
}

private extension DelegateProxy {
    static func collectSelectors(p: Protocol) -> Set<Selector> {
        var selectors = Set<Selector>()
        
        var protocolMethodCount: UInt32 = 0
        let methodDescriptions = protocol_copyMethodDescriptionList(p, false, true, &protocolMethodCount)
        
        (0..<protocolMethodCount).forEach {
            let methodDescription = methodDescriptions[Int($0)]
            if DP_IsMethodReturnTypeVoid(methodDescription) {
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
}