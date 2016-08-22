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
import Bond

final class RACReceiver: Receivable {
    let (signal, observer) = Signal<Arguments, NoError>.pipe()
    
    func send(arguments: Arguments) {
        observer.sendNext(arguments)
    }
}

final class BondReceiver: Receivable {
    let subject = EventProducer<Arguments>()
    
    func send(arguments: Arguments) {
        subject.next(arguments)
    }
}

extension DelegateProxy {
    func rac_receive(selector: Selector...) -> Signal<Arguments, NoError> {
        return RACReceiver().subscribeTo(proxy: self, selectors: selector).signal
    }
    
    func bnd_receive(selector: Selector...) -> EventProducer<Arguments> {
        return BondReceiver().subscribeTo(proxy: self, selectors: selector).subject
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

public final class WebViewDelegateProxy: DelegateProxy, UIWebViewDelegate, DelegateProxyType {
    public func resetDelegateProxy(owner: UIWebView) {
        owner.delegate = self
    }
}

extension UITextView {
    var textChange: Signal<Arguments, NoError> {
        return delegateProxy.rac_receive(#selector(UITextViewDelegate.textViewDidChange(_:)))
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

extension UIWebView {
    var delegateProxy: WebViewDelegateProxy {
        return WebViewDelegateProxy.proxyFor(self)
    }
}

final class ViewController: UIViewController {
    @IBOutlet private weak var lTextView: UITextView!
    @IBOutlet private weak var rTextView: UITextView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var webView: UIWebView!
    
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
        webView.loadRequest(.init(URL: NSURL(string: "https://www.google.com")!))
        webView.delegateProxy
            .rac_receive(#selector(UIWebViewDelegate.webViewDidFinishLoad(_:)))
            .map { $0.value(0, as: UIWebView.self) }
            .ignoreNil()
            .observeNext { print("Page loaded: \($0)") }
        
        webView.scrollView.delegateProxy
            .bnd_receive(#selector(UIScrollViewDelegate.scrollViewDidScroll(_:)))
            .map { $0.value(0, as: UIScrollView.self)?.contentOffset.y }
            .ignoreNil()
            .observeNew { print("Web content offset: \($0)") }
        
        lTextView.textChange
            .map { $0.value(0, as: UITextView.self)?.text }
            .ignoreNil()
            .skipRepeats()
            .observeNext { print("Left: \($0)") }
        
        rTextView.delegateProxy
            .rac_receive(#selector(UITextViewDelegate.textViewDidChange(_:)))
            .map { $0.value(0, as: UITextView.self)?.text }
            .ignoreNil()
            .skipRepeats()
            .observeNext { print("Right: \($0)")}
        
        scrollView.delegateProxy
            .rac_receive(#selector(UIScrollViewDelegate.scrollViewDidScroll(_:)))
            .map { $0.value(0, as: UIScrollView.self)?.contentOffset.y }
            .ignoreNil()
            .observeNext { print("ContentOffset: \($0)") }
    }
}