//
//  SignupViewController.swift
//  Rolex
//
//  Created by J J Feddock on 1/20/19.
//  Copyright © 2019 JF Corporation. All rights reserved.
//

import UIKit
import Parse

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var groupIDInput: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    
    let prefs = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func submitClicked(_ sender: Any) {
        submitNewUser(username: usernameInput.text, password: passwordInput.text, groupID: groupIDInput.text)
    }

    func submitNewUser(username: String?, password: String?, groupID: String?) {
        var user = PFUser()
        user.username = username
        user.password = password
        user["deviceID"] = UIDevice.current.identifierForVendor?.uuidString
        // other fields can be set just like with PFObject
        user["group"] = groupID
        user["points"] = 0
        
        user.signUpInBackground {
            (success, error) -> Void in
            if let error = error {
                let errorString = error.localizedDescription
                // Show the errorString somewhere and let the user try again.
                let alert = UIAlertController(title: "Uh Oh!", message: "There was an error: \(String(describing: errorString)). Did you fill in all the fields? If this persists let us know", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            } else {
                // Hooray! Let them use the app now.
                let alert = UIAlertController(title: "Yay!", message: "User: \(String(describing: username)) was created. Press OK to continue", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    self.prefs.set(username!, forKey: "currentUser")
                    self.prefs.synchronize()
                    let viewController:UIViewController = self.storyboard!.instantiateViewController(withIdentifier: "Main") as UIViewController
                    self.present(viewController, animated: false, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
            }
    }
    
    
    // --- MARK: Keyboard Manager ---
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        let realOrigin = textField.convert(textField.frame.origin, to: self.view)
        let bottomSpace = self.view.frame.maxY - (textField.frame.height + realOrigin.y)
        //        print(bottomSpace)
        if bottomSpace < 300 {
            UIView.animate(withDuration: 0.75, animations: {
                self.view.bounds.origin.y = 60
            })
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        let realOrigin = textField.convert(textField.frame.origin, to: self.view)
        let bottomSpace = self.view.frame.maxY - (textField.frame.height + realOrigin.y)
        //        print(bottomSpace)
        if bottomSpace < 300 {
            UIView.animate(withDuration: 0.75, animations: {
                self.view.bounds.origin.y = 0
            })
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
