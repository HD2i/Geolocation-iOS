//
//  ReloadBalanceViewController.swift
//  Geolocation
//
//  Created by Matt Johnson on 1/21/19.
//  Copyright © 2019 Matt Johnson. All rights reserved.
//

import UIKit
import WebKit

class ReloadBalanceViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myURLString = "https://faucet.oasiscloud.io/"
        let url = NSURL(string: myURLString)
        let request = NSURLRequest(url: url! as URL)
        //webView = WKWebView(frame: self.view.frame)
       
        
        
        webView.navigationDelegate = self
        webView.load(request as URLRequest)

        // Do any additional setup after loading the view.
    }
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}

extension ReloadBalanceViewController: WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Strat to load")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish to load")
    }
}
