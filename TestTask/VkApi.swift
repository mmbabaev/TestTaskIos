//
//  VkApi.swift
//  TestTask
//
//  Created by Михаил on 13.01.16.
//  Copyright © 2016 Mihail. All rights reserved.
//

import Foundation
import SwiftyJSON

class VkApi {
    // синглтон VkApi
    static let sharedInstance = VkApi()
    
    var isAuthorization = false
    
    func likePressed(sender: UIButton, post: PostItem, completeBlock: () -> Void) {
        sender.selected = !sender.selected
        
        let method = sender.selected ? "add" : "delete"
        VkApi.sharedInstance.sendRequest("likes.\(method)?type=post&owner_id=\(post.source.id)&item_id=\(post.id)") {
            data, error in
            if let likes = data?["response"]["likes"].intValue {
                post.likes = likes
                post.isLiked = sender.selected
                
                completeBlock()
            }
        }

    }
    
    func sendRequest(method: String, completeBlock: (data: JSON?, error: NSError?) -> Void) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let request = createRequest(method)
        print(request.URL?.absoluteString)
        let session = NSURLSession.sharedSession()
    
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            if data != nil {
                let dict = JSON(data: data!)
                completeBlock(data: dict, error: error)
            }
            else {
                NSLog("ERROR: \(error?.localizedDescription)")
                completeBlock(data: nil, error: error)
            }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        task.resume()
    }
    
    func createRequest(method: String) -> NSMutableURLRequest {
        let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
        let urlString = "https://api.vk.com/method/\(method)&access_token=\(token)"
        
        NSLog("Sending request: \(urlString)")
        return NSMutableURLRequest(URL: NSURL(string: urlString)!)
    }
}