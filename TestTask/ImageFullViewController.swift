//
//  ImageFullViewController.swift
//  TestTask
//
//  Created by Михаил on 18.01.16.
//  Copyright © 2016 Mihail. All rights reserved.
//

import UIKit

class ImageFullViewController: UIViewController, UIScrollViewDelegate {

    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView = UIScrollView(frame: UIScreen.mainScreen().bounds)
        imageView = UIImageView(image: image)
        imageView.frame = scrollView.frame
        imageView.contentMode = .ScaleAspectFit
        scrollView.addSubview(imageView)
        scrollView.contentSize = image.size
        
        scrollView.delegate = self
        
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 5.0
        
        scrollView.zoomScale = 1.0;
        
        self.view.addSubview(scrollView)
        centerScrollViewContents()
    }
    
    func centerScrollViewContents() {
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        imageView.frame = contentsFrame
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
