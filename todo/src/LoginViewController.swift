//
//  LoginViewController.swift
//  todo
//
//  Created by Quyen Castellanos on 3/10/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    // UI Elements
    
    @IBOutlet weak var usernameInputField: UITextField!
    @IBOutlet weak var passwordInputField: UITextField!
    
    // Class variables
    private var validInput = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameInputField.delegate = self
        self.passwordInputField.delegate = self
        self.passwordInputField.secureTextEntry = true
        loadAllCourses()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "enterApplication" {
//            let usernameInput = usernameInputField.text!
//            let passwordInput = passwordInputField.text!
             let usernameInput = "qac68"
             let passwordInput = "password123"
            
            // Check that username and password are non-empty
            if usernameInput.characters.count < 1 || passwordInput.characters.count < 1 {
                alert(self, description: "Please enter a username and password.", action: UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                return false
            }
            
            // If not empty, continue with user authentication
            // Look up the email address according to username
            print("username = \(usernameInput)")
                
            loginUser(self, username: usernameInput, password: passwordInput, segueIdentifier: identifier)
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}
