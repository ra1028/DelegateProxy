//
//  ViewController.swift
//  DelegateProxyDemo
//
//  Created by Ryo Aoyama on 8/12/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import UIKit
import DelegateProxy
import ReactiveCocoa
import Result

final class DelegateReceiver: Receivable {
    let (signal, observer) = Signal<Arguments, NoError>.pipe()
    
    func send(arguments: Arguments) {
        observer.sendNext(arguments)
    }
}

extension DelegateProxy {
    func receiveSignal(selector: Selector...) -> Signal<Arguments, NoError> {
        return DelegateReceiver().registerTo(proxy: self, selectors: selector).signal
    }
}

public final class TextViewDelegateProxy: DelegateProxy, UITextViewDelegate, DelegateProxyType {
    public func resetDelegateProxy(owner: UITextView) {
        owner.delegate = self
    }
}

public final class ScrollViewDelegateProxy: DelegateProxy, UIScrollViewDelegate, DelegateProxyType {
    public func resetDelegateProxy(owner: UIScrollView) {
        owner.delegate = self
    }
}

extension UITextView {
    var textChange: Signal<Arguments, NoError> {
        return delegateProxy.receiveSignal(#selector(UITextViewDelegate.textViewDidChange(_:)))
    }
    
    override var delegateProxy: DelegateProxy {
        return TextViewDelegateProxy.proxyFor(self)
    }
}

extension UIScrollView {
    var delegateProxy: DelegateProxy {
        return ScrollViewDelegateProxy.proxyFor(self)
    }
}

final class ViewController: UIViewController {
    @IBOutlet private weak var lTextView: UITextView!
    @IBOutlet private weak var rTextView: UITextView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.contentSize = CGSize(
            width: scrollView.bounds.width,
            height: scrollView.bounds.height * 3
        )
    }
}

private extension ViewController {
    func configure() {
//        lTextView.delegateProxy
//            .receive(#selector(UITextViewDelegate.textViewDidChange(_:))) {
//                guard let tv: UITextView = $0.value(0) else { return }
//                print("Left: \(tv.text)")
//        }
//        
//        rTextView.delegateProxy
//            .receive(#selector(UITextViewDelegate.textViewDidChange(_:))) {
//                guard let tv: UITextView = $0.value(0) else { return }
//                print("Right: \(tv.text)")
//        }
        
        lTextView.textChange
            .map { $0.value(0, as: UITextView.self)?.text }
            .ignoreNil()
            .skipRepeats()
            .observeNext { print("Left: \($0)") }
        
        rTextView.delegateProxy
            .receiveSignal(#selector(UITextViewDelegate.textViewDidChange(_:)))
            .map { $0.value(0, as: UITextView.self)?.text }
            .ignoreNil()
            .skipRepeats()
            .observeNext { print("Right: \($0)")}
        
        scrollView.delegateProxy
            .receiveSignal(#selector(UIScrollViewDelegate.scrollViewDidScroll(_:)))
            .map { $0.value(0, as: UIScrollView.self)?.contentOffset.y }
            .ignoreNil()
            .observeNext { print("ContentOffset: \($0)") }
    }
}