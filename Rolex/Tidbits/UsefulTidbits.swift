//
//  UsefulTidbits.swift
//  Locktime
//
//  Created by J J Feddock on 1/23/19.
//  Copyright © 2019 HF Corporation. All rights reserved.
//

import UIKit

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


class UsefulTidbits: NSObject {

}
