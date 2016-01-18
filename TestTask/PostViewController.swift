//
//  PostViewController.swift
//  TestTask
//
//  Created by Михаил on 15.01.16.
//  Copyright © 2016 Mihail. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

    var textView: UITextView!
    var collectionView: UICollectionView!
    
    var post: PostItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = post.source.name
        let bounds = UIScreen.mainScreen().bounds
        
        let textViewFrame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height / 2)
        textView = UITextView(frame: textViewFrame)
        
        
        let collectionFrame = CGRect(x: 0, y: bounds.height / 2, width: bounds.width, height: bounds.height / 2)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(100, 100)
        layout.scrollDirection = .Vertical
        
        collectionView = UICollectionView(frame: collectionFrame, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerNib(UINib(nibName: "ImageItem", bundle: nil), forCellWithReuseIdentifier: "imageCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        textView.editable = false
        textView.text = post.text
        textView.font = UIFont.systemFontOfSize(17)
        self.view.addSubview(textView)
        self.view.addSubview(collectionView)
        collectionView.reloadData()
    }
}

extension PostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post.photos.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! ImageCollectionViewCell
        let photo = post.photos[indexPath.row]
        cell.imageView.image = photo.image
        cell.imageView.contentMode = .ScaleAspectFit
        
        if photo.state == .New {
            let op = ImageDownloader(photo: photo)
            op.completionBlock = {
                dispatch_async(dispatch_get_main_queue(), {
                    self.collectionView.reloadItemsAtIndexPaths([indexPath])
                })
            }
            NSOperationQueue().addOperation(op)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let imageVC = ImageFullViewController()
        imageVC.image = post.photos[indexPath.row].image
        self.showViewController(imageVC, sender: self)
    }
}