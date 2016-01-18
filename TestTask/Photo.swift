//
//  Photo.swift
//  TestTask
//
//  Created by Михаил on 13.01.16.
//  Copyright © 2016 Mihail. All rights reserved.
//

import Foundation
import UIKit

// Состояния, в которых может находиться фотография
enum PhotoState {
    case New, Downloaded, Failed
}

class Photo {
    var state = PhotoState.New
    let url: String
    var image = UIImage(named: "new.jpg")
    
    init(url: String) {
        self.url = url
    }
}