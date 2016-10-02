//
//  Arguments.swift
//  DelegateProxy
//
//  Created by Ryo Aoyama on 8/10/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

public final class Arguments {
    public let list: [Any]
    
    init(_ args: [Any]) {
        self.list = args
    }
}

public extension Arguments {
    func value(at: Int) -> Any? {
        guard list.count > at else { return nil }
        return list[at]
    }
    
    func value<T>(at: Int, as: T.Type = T.self) -> T? {
        return value(at: at) as? T
    }
}
