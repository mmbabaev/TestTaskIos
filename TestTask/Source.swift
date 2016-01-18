//
//  Source.swift
//  TestTask
//
//  Created by Михаил on 13.01.16.
//  Copyright © 2016 Mihail. All rights reserved.
//

import Foundation
import UIKit

/*
    Источник новостного поста
*/
class Source {
    var name: String
    var id: String
    var photo: Photo
    
    init(id: String, name: String, imageUrl: String) {
        self.id = id
        self.name = name
        self.photo = Photo(url: imageUrl)
    }
}