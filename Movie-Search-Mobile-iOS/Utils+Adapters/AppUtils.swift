//
//  AppUtils.swift
//  Movie-Search-Mobile-iOS
//
//  Created by Imad on 4/17/18.
//  Copyright © 2018 Imad. All rights reserved.
//

import UIKit

class AppUtils: NSObject {

    class func showAlert(title:String, mesg:String, controller:AnyObject) {
        let alertController = UIAlertController(title: title, message: mesg, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        controller.present(alertController, animated: true, completion: nil)
    }
}
