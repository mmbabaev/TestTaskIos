//
//  PostOperations.swift
//  TestTask
//
//  Created by Михаил on 14.01.16.
//  Copyright © 2016 Mihail. All rights reserved.
//

import Foundation
import UIKit

class ImageDownloader: NSOperation {
    let photo: Photo
    
    init(photo: Photo) {
        self.photo = photo
    }
    
    override func main() {
        if self.cancelled {
            return
        }
        
        let url = NSURL(string: (photo.url))
        
        if let imageUrl = url {
            if self.cancelled {
                return
            }
            let data = NSData(contentsOfURL: imageUrl)
            
            if let imageData = data {
                photo.image = UIImage(data: imageData)
                photo.state = .Downloaded
                return
            }
        }
        
        photo.state = .Failed
    }
}