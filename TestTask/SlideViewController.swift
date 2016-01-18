//
//  SlideViewController.swift
//  TestTask
//
//  Created by Михаил on 16.01.16.
//  Copyright © 2016 Mihail. All rights reserved.
//

import UIKit

class SlideViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let buttonNames = ["Новости", "Друзья", "Сообщества"]
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bounds = UIScreen.mainScreen().bounds
        
        let viewFrame = CGRect(x: 0, y: 0, width: bounds.width, height: 40)
        let supportView = UIView(frame: viewFrame)
        supportView.backgroundColor = UIColor.whiteColor()
        
        let tableViewFrame = CGRect(x: 0, y: 40, width: bounds.width, height: bounds.height - 40)
        tableView = UITableView(frame: tableViewFrame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "slideCell")
        
        view.addSubview(supportView)
        view.addSubview(tableView)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let newsFeedVC = NewsFeedViewController()
        newsFeedVC.title = buttonNames[indexPath.row]
        
        switch indexPath.row {
        case 0: newsFeedVC.postType = .All
        case 1: newsFeedVC.postType = .Friend
        case 2: newsFeedVC.postType = .Community
        default: break
        }
        
        self.mm_drawerController.centerViewController =
            UINavigationController(rootViewController: newsFeedVC)
        self.mm_drawerController.closeDrawerAnimated(true, completion: nil)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("slideCell", forIndexPath: indexPath)
        cell.textLabel?.text = buttonNames[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttonNames.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
