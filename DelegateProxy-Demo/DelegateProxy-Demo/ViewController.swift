//
//  ViewController.swift
//  DelegateProxy-Demo
//
//  Created by 青山 遼 on 2016/08/10.
//  Copyright © 2016年 青山 遼. All rights reserved.
//

import UIKit
import DelegateProxy

final class TextViewDelegateProxy: DelegateProxy, UITextViewDelegate {}

final class ViewController: UIViewController {
    @IBOutlet private weak var textView: UITextView!
    
    private let delegateProxy = TextViewDelegateProxy()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

private extension ViewController {
    func configure() {
        textView.delegate = delegateProxy
        
        delegateProxy.receive(#selector(UITextViewDelegate.textViewDidChange(_:))) {
            guard let tv = $0[0] as? UITextView else { return }
            print(tv.text)
        }
    }
}