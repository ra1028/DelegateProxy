//
//  ViewController.swift
//  DelegateProxy-Demo
//
//  Created by 青山 遼 on 2016/08/10.
//  Copyright © 2016年 青山 遼. All rights reserved.
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
                guard let tv = $0[0] as? UITextView else { return }
                print("Left: \(tv.text)")
        }
        
        rTextView.delegateProxy
            .receive(#selector(UITextViewDelegate.textViewDidChange(_:))) {
                guard let tv = $0[0] as? UITextView else { return }
                print("Right: \(tv.text)")
        }
    }
}