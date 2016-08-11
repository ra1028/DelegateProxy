//
//  ViewController.swift
//  DelegateProxy-Demo
//
//  Created by Ryo Aoyama on 8/8/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import UIKit
import DelegateProxy

public final class TextViewDelegateProxy: DelegateProxy, UITextViewDelegate {}

extension UITextView: DelegateForwardable {
    public static func createDelegateProxy() -> TextViewDelegateProxy {
        return .init()
    }
    
    public func setDelegateProxy(proxy: TextViewDelegateProxy) {
        delegate = proxy
    }
}

final class ViewController: UIViewController {
    @IBOutlet private weak var lTextView: UITextView!
    @IBOutlet private weak var rTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()        
    }
}

private extension ViewController {
    func configure() {
        lTextView.delegateProxy
            .receive(#selector(UITextViewDelegate.textViewDidChange(_:))) {
                guard let tv: UITextView = $0.value(0) else { return }
                print("Left: \(tv.text)")
        }
        
        rTextView.delegateProxy
            .receive(#selector(UITextViewDelegate.textViewDidChange(_:))) {
                guard let tv: UITextView = $0.value(0) else { return }
                print("Right: \(tv.text)")
        }
    }
}