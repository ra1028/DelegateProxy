//: Playground - noun: a place where people can play

import UIKit
import DelegateProxy

@objc protocol SampleDelegate {
    optional func something(message: NSRange)
    optional func other()
}

final class Sample: NSObject {
    weak var delegate: SampleDelegate?
    
    func doIt() {
        delegate?.something!(.init(location: 30, length: 20))
    }
    
    func other() {
        delegate?.other!()
    }
}

final class SampleDelegateProxy: DelegateProxy, SampleDelegate {}

let sample = Sample()
let delegateProxy = SampleDelegateProxy()
sample.delegate = delegateProxy

delegateProxy.receive(
    #selector(SampleDelegate.other),
    #selector(SampleDelegate.something(_:))
) {
    print($0)
    return
}

//sample.doIt()
sample.other()
