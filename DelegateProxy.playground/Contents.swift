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

final class SampleDelegateProxy: DelegateProxy, SampleDelegate {
    private(set) lazy var observer: DelegateObserver = DelegateObserver().registerTo(
        self, selector: #selector(SampleDelegate.other), #selector(SampleDelegate.something(_:))
    )
}

let sample = Sample()
let delegateProxy = SampleDelegateProxy()
sample.delegate = delegateProxy

delegateProxy.observer.observe {
    print($0)
    return
}

sample.doIt()
sample.other()
