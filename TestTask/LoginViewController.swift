//
//  ViewController.swift
//  TestTask
//
//  Created by Михаил on 12.01.16.
//  Copyright © 2016 Mihail. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UIWebViewDelegate {
    
    let vkAppId = "5224588"
    var vkWebView: UIWebView!
    var delegate: AuthorizationDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vkWebView = UIWebView(frame: UIScreen.mainScreen().bounds)
        vkWebView.scalesPageToFit = true
        vkWebView.delegate = self
        self.view.addSubview(vkWebView)
        
        let authorizeLink = "http://api.vk.com/oauth/authorize?client_id=\(vkAppId)&scope=wall,friends&redirect_uri=http://api.vk.com/blank.html&display=touch&response_type=token"
        let request = NSURLRequest(URL: NSURL(string: authorizeLink)!)
        vkWebView.loadRequest(request)
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        if let result = webView.request?.URL?.absoluteString {
            if !result.containsString("access_token") {
                return
            }
            
            let accessToken = result.urlValueForKey("access_token")
            let userId = result.urlValueForKey("user_id")

            NSLog("Access token = \(accessToken)\nUser id = \(userId)")
            
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(accessToken, forKey: "token")
            defaults.setObject(userId, forKey: "userId")
            defaults.setObject(NSDate(), forKey: "tokenDate")
            defaults.synchronize()
            delegate.successfulAuth()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        let message = error?.localizedDescription
        NSLog("ERROR: \(message)")
        
        if message != nil {
            showAlert(message!)
        }
        else {
            showAlert("Произошла ошибка")
        }
    }
}



















