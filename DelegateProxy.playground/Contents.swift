//: Playground - noun: a place where people can play

import UIKit
import DelegateProxy

@objc protocol SampleDelegate {
    optional func something()
}

final class Sample: NSObject {
    weak var delegate: SampleDelegate?
    
    func doIt() {
        delegate?.something?()
    }
}

final class SampleDelegateProxy: DelegateProxy, SampleDelegate {}

let sample = Sample()
let delegateProxy = SampleDelegateProxy()
sample.delegate = delegateProxy