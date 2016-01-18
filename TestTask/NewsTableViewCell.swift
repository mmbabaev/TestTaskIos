//
//  NewsTableViewCell.swift
//  TestTask
//
//  Created by Михаил on 13.01.16.
//  Copyright © 2016 Mihail. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var ownerImageView: UIImageView!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var newsTextLabel: UILabel!
    
    var indexPath: NSIndexPath!
}
