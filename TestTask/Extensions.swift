//
//  Extensions.swift
//  TestTask
//
//  Created by Михаил on 13.01.16.
//  Copyright © 2016 Mihail. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func urlValueForKey(key: String) -> String? {
        let range = self.rangeOfString("(?<=\(key)=)[^&]*", options:.RegularExpressionSearch)
        return self.substringWithRange(range!)
    }
}

extension UIViewController {
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Ошибка", message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}