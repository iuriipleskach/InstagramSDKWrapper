//
//  ViewController.swift
//  InstagramSDK
//
//  Created by Iurii Pleskach on 9/15/17.
//  Copyright © 2017 Iurii Pleskach. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var webView: WKWebView!

    @IBAction func didTapButton(_ sender: Any) {
    }

    //TODO: implement the interface similar to SwiftyDropbox autorizeFromViewController ??
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.navigationDelegate = self
        
        guard let url = InstagramManager.shared.autorizationURL(for: .publicContent) else {
            print("No autorization url")
            return
        }
        let request = URLRequest(url: url)
        self.webView.load(request)
    }

    // MARK: WKNavigationDelegate
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let accessToken = InstagramManager.shared.token(from: navigationAction.request.url!) else {
            decisionHandler(.allow)
            return
        }
        InstagramManager.shared.accessToken = accessToken
        print(accessToken)
        let instagramManager = InstagramManager.shared
        _ = instagramManager.requestUser(with: "yuriy") { (users, error) in
            if let firstUserId = users?.first?.id {
                _ = instagramManager.requestMediafiles(userId: firstUserId) { (mediafiles, error) in
                    print(mediafiles)
                }
            }
        }
        
        // Stop navigation if redirect url is passed
        decisionHandler(.cancel)
    }
}

