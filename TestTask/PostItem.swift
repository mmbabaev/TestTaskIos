//
//  News.swift
//  TestTask
//
//  Created by Михаил on 13.01.16.
//  Copyright © 2016 Mihail. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 Объект новости
*/
class PostItem {
    let text: String
    let source: Source
    let date: String
    let copyOwnerId: String
    let copyPostDate: String
    var likes: Int
    var photos = [Photo]()
    var isLiked: Bool
    let id: String
    
    var firstPhoto: Photo? {
        if photos.count == 0 {
            return nil
        }
        else {
            return photos[0]
        }
    }
    
    init(json: JSON, profiles: JSON, groups: JSON) {
        id = json["post_id"].stringValue
        text = json["text"].stringValue
        let sourceId = json["source_id"].intValue
        
        var name = ""
        var imageUrl = ""
        if sourceId > 0 {
            for profile in profiles.arrayValue {
                if sourceId == profile["uid"].intValue {
                    name = profile["last_name"].stringValue + " " + profile["first_name"].stringValue
                    imageUrl = profile["photo"].stringValue
                    break
                }
            }
        }
        else {
            for group in groups.arrayValue {
                if sourceId == (0 - group["gid"].intValue) {
                    name = group["name"].stringValue
                    imageUrl = group["photo"].stringValue
                    break
                }
            }
        }
        
        source = Source(id: String(sourceId), name: name, imageUrl: imageUrl)
        likes = Int(json["likes"]["count"].stringValue)!
        date = json["date"].stringValue
        copyOwnerId = json["copy_owner_id"].stringValue
        copyPostDate = json["copy_post_date"].stringValue
        isLiked = json["likes"]["user_likes"].int == 1
        likes = json["likes"]["count"].int!
        
        
        for attachment in json["attachments"].arrayValue {
            if attachment["type"] == "photo" {
                let photo = attachment["photo"]
                
                photos.append(Photo(url: photo["src_big"].stringValue))
            }
        }
    }
}