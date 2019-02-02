//
//  SigninViewController.swift
//  Rolex
//
//  Created by J J Feddock on 1/20/19.
//  Copyright © 2019 JF Corporation. All rights reserved.
//

import UIKit
import Parse

class SigninViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if PFUser.current() != nil {
            let viewController:UIViewController = self.storyboard!.instantiateViewController(withIdentifier: "Main") as UIViewController
            self.present(viewController, animated: false, completion: nil)
        }
    }
    
    @IBAction func submitClick(_ sender: Any) {
        PFUser.logInWithUsername(inBackground: self.usernameInput.text!, password:self.passwordInput.text!) {
            (user: PFUser?, error: Error?) -> Void in
            if let error = error {
                let errorString = error.localizedDescription
                // Show the errorString somewhere and let the user try again.
                let alert = UIAlertController(title: "Uh Oh!", message: "There was an error: \(String(describing: errorString)). If this persists let us know", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            } else {
                // Hooray! Let them use the app now.
                let viewController:UIViewController = self.storyboard!.instantiateViewController(withIdentifier: "Main") as UIViewController
                self.present(viewController, animated: false, completion: nil)
            }
        }
    }
    
    
    @IBAction func SignUp(_ sender: Any) {
        let viewController:UIViewController = self.storyboard!.instantiateViewController(withIdentifier: "Signup") as UIViewController
        self.present(viewController, animated: false, completion: nil)
    }
    
    
    // --- MARK: Keyboard Manager ---
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        let realOrigin = textField.convert(textField.frame.origin, to: self.view)
        let bottomSpace = self.view.frame.maxY - (textField.frame.height + realOrigin.y)
//        print(bottomSpace)
        if bottomSpace < 300 {
            UIView.animate(withDuration: 0.75, animations: {
                self.view.bounds.origin.y = 300-bottomSpace
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
