//
//  DelegateProxy.swift
//  DelegateProxy
//
//  Created by Ryo Aoyama on 8/8/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

public class DelegateProxy: DPDelegateProxy {
    private static var selectorsOfClass = [NSValue: Set<Selector>]()
    
    public override class func initialize() {
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
    
    public override func interceptedSelector(selector: Selector, arguments: [AnyObject]) {
        
    }
}

private extension DelegateProxy {
    static func collectSelectors(p: Protocol) -> Set<Selector> {
        var selectors = Set<Selector>()
        
        var protocolMethodCount: UInt32 = 0
        let methodDescriptions = protocol_copyMethodDescriptionList(p, false, true, &protocolMethodCount)
        
        (0..<protocolMethodCount).forEach {
            let methodDescription = methodDescriptions[Int($0)]
            if isMethodReturnTypeVoid(methodDescription) {
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