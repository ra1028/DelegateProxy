//
//  Receivable.swift
//  DelegateProxy
//
//  Created by Ryo Aoyama on 8/10/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

public protocol Receivable {
    func send(arguments: Arguments)
}

public extension Receivable {
    @discardableResult
    func subscribeTo(proxy: DelegateProxy, selector: Selector...) -> Self {
        subscribeTo(proxy: proxy, selectors: selector)
        return self
    }
    
    @discardableResult
    func subscribeTo(proxy: DelegateProxy, selectors: [Selector]) -> Self {
        proxy.receive(selectors: selectors, receiver: self)
        return self
    }
}
