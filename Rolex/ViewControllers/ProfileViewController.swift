//
//  ThirdViewController.swift
//  Rolex
//
//  Created by J J Feddock on 1/10/19.
//  Copyright © 2019 JF Corporation. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var usernameViewBox: UIView!
    @IBOutlet weak var groupViewBox: UIView!
    @IBOutlet weak var usernameTextView: UITextField!
    @IBOutlet weak var groupTextView: UITextField!
    
    @IBOutlet weak var editButton: UIButton!
    
    var currUser: PFUser = PFUser()
    var currEditing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let temp = PFUser.current() {
            currUser = temp
        } else {
            dismiss(animated: true, completion: nil)
        }
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addValues()
    }
    
    func addValues() {
        groupViewBox.layer.cornerRadius = 8
        usernameViewBox.layer.cornerRadius = 8
        
        usernameTextView.isUserInteractionEnabled = false
        groupTextView.isUserInteractionEnabled = false
        
        usernameTextView.text = currUser.username
        groupTextView.text = currUser["group"] as? String ?? "No Group"
    }
    
    
    @IBAction func logOutAction(_ sender: Any) {
        PFUser.logOut()
        
        let viewController:UIViewController = self.storyboard!.instantiateViewController(withIdentifier: "Signin") as UIViewController
        self.present(viewController, animated: false, completion: nil)
    }
    
    @IBAction func editAction(_ sender: Any) {
        if (currEditing) {
            currEditing = false
            
            usernameTextView.isUserInteractionEnabled = false
            groupTextView.isUserInteractionEnabled = false
            editButton.setTitle("Edit", for: .normal)
            
            currUser.username = usernameTextView.text
            currUser["group"] = groupTextView.text
            currUser.saveInBackground()
        } else {
            currEditing = true
            
            usernameTextView.isUserInteractionEnabled = true
            groupTextView.isUserInteractionEnabled = true
            editButton.setTitle("Submit", for: .normal)
        }
    }
    
    
    // --- MARK: Keyboard Manager ---
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        let realOrigin = textField.convert(textField.frame.origin, to: self.view)
        let bottomSpace = self.view.frame.maxY - (textField.frame.height + realOrigin.y)

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
