//
//  NewsFeedViewController.swift
//  TestTask
//
//  Created by Михаил on 13.01.16.
//  Copyright © 2016 Mihail. All rights reserved.
//

import UIKit

protocol AuthorizationDelegate {
    func successfulAuth()
}

protocol SourceDelegate {
    func updateCellAtIndexPath(indexPath: NSIndexPath)
}

// Типы постов для отображения
enum PostType {
    case Friend, Community, All
}

class NewsFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AuthorizationDelegate, SourceDelegate {
    
    var tableView: UITableView!
    
    // с какой новости подгружать далее
    var nextFrom = ""
    var news = [PostItem]()
    let queue = NSOperationQueue()
    let api = VkApi.sharedInstance
    
    var isAuthorization: Bool {
        get { return api.isAuthorization }
        set { api.isAuthorization = newValue }
    }
    
    var postType: PostType = .All
    
    override func viewDidLoad() {
        queue.maxConcurrentOperationCount = 1
        
        tableView = UITableView(frame: UIScreen.mainScreen().bounds)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.registerNib(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "postCell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "loadCell")
        view.addSubview(tableView)
        
        let leftBarButton = UIBarButtonItem(image: UIImage(named: "menu"), style: .Plain, target: self, action: "showSlideMenu:")
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "reload-25"),
            style: .Plain, target: self, action: "reloadNewsFeed:")
        
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    override func viewWillAppear(animated: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("token") == nil {
            presentLoginVC()
            return
        }
        
        if news.count == 0 {
            loadNextNews()
        }
    }
    
    func loadNextNews() {
        while queue.operationCount != 0 {}
        
        var next = "offset=\(nextFrom)&"
        if nextFrom == "" {
            next = ""
        }
        api.sendRequest("newsfeed.get?filters=post&\(next)count=30") {
            data, error in
            if data != nil {
                let response = data!["response"]
                self.nextFrom = response["new_offset"].stringValue
    
                let items = response["items"].arrayValue
                
                for item in items {
                    let id = item["post_id"].stringValue
                    
                    // Убираем новости, которые уже встречались
                    if (self.news.filter { $0.id == id }).count == 0 {
                        let post = PostItem(json: item, profiles: response["profiles"], groups: response["groups"])
                        
                        // в зависимости от типа отображаемых новостей выбираем отображать ли пост
                        var isNeedToAdd = true
                        let sourceId = Int(post.source.id)!
                        switch self.postType {
                        case .Friend:
                            if sourceId < 0 {
                                isNeedToAdd = false
                            }
                        case .Community:
                            if sourceId > 0 {
                                isNeedToAdd = false
                            }
                        case .All: break
                        }
                        
                        if isNeedToAdd {
                            self.news.append(post)
                        }
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
            
            if error != nil {
                NSLog("Error: \(error!.localizedDescription)")

                self.showAlert("Не удается загрузить новости")
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count + 1 // последняя ячейка - кнопка "Загрузить далее"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if UIApplication.sharedApplication().networkActivityIndicatorVisible {
            return
        }
        
        if indexPath.row == news.count {
            loadNextNews()
            return
        }
        else {
            let postVC = PostViewController()
            postVC.post = news[indexPath.row]
            self.showViewController(postVC, sender: self)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == news.count {
            let cell = tableView.dequeueReusableCellWithIdentifier("loadCell", forIndexPath: indexPath)
            cell.textLabel?.text = "Загрузить далее"
            cell.textLabel?.textAlignment = NSTextAlignment.Center
            cell.textLabel?.font = UIFont(name: "System", size: 17.0)
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as! NewsTableViewCell
        let item = news[indexPath.row]
        cell.ownerLabel.text = item.source.name
        cell.likeButton.selected = item.isLiked
        cell.likeButton.contentMode = .ScaleAspectFit
        cell.likeButton.addTarget(self, action: "likeClicked:", forControlEvents: .TouchDown)
        cell.newsTextLabel.text = item.text
        cell.newsTextLabel.lineBreakMode = .ByTruncatingTail
        cell.likesCountLabel.text = String(item.likes)
        
        cell.postImageView.contentMode = .ScaleAspectFit
        cell.postImageView.image = item.firstPhoto?.image
        
        cell.ownerImageView.contentMode = .ScaleAspectFit
        cell.ownerImageView.image = item.source.photo.image
        
        if let photo = item.firstPhoto {
            switch photo.state {
            case .New:
                let op = ImageDownloader(photo: photo)
                op.completionBlock = {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    })
                }
                queue.addOperation(op)
            default: break
            }
        }
        
        switch item.source.photo.state {
        case .New:
            let op = ImageDownloader(photo: item.source.photo)
            
            op.completionBlock = {
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                })
            }
            queue.addOperation(op)
        default: break
        }
        
        cell.indexPath = indexPath
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == news.count {
            return 50
        }
        else {
            if news[indexPath.row].firstPhoto == nil {
                return 150
            }
            return 350
        }
    }
    
    func reloadNewsFeed(sender: UIButton) {
        let newsFeedVC = NewsFeedViewController()
        newsFeedVC.title = self.title
        newsFeedVC.postType = self.postType
        
        self.mm_drawerController.centerViewController =
            UINavigationController(rootViewController: newsFeedVC)
    }
    
    func showSlideMenu(sender: UIButton) {
        self.mm_drawerController.toggleDrawerSide(.Left, animated: true, completion: nil)
    }
    
    func likeClicked(sender: UIButton) {
        let cell = sender.superview!.superview as! NewsTableViewCell
        let row = cell.indexPath.row
        let post = news[row]
        
        VkApi.sharedInstance.likePressed(sender, post: post) {
            dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadRowsAtIndexPaths([cell.indexPath], withRowAnimation: .None)
            }
        }
    }

    func updateCellAtIndexPath(indexPath: NSIndexPath) {
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func successfulAuth() {
        isAuthorization = true
    }
    
    func presentLoginVC() {
        let loginVC = LoginViewController()
        loginVC.delegate = self
        self.presentViewController(loginVC, animated: true, completion: nil)
    }
}




















