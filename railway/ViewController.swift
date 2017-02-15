//
//  ViewController.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-01-28.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit


class ViewController: UIViewController{
    
    let userDefaults = Foundation.UserDefaults.standard
    
    //MARK: Properties
    @IBOutlet weak var emailLogin: UITextField!
    @IBOutlet weak var passwordLogin: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Check that email input is provided
    func validateEmail() -> String {
        let email: String! = self.emailLogin.text
        print (email)
        return email
    }
    
    // Check that password input is provided
    func validatePassword() -> String {
        let password: String! = self.passwordLogin.text
        print(password)
        return password
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        let email = validateEmail()
        let password = validatePassword()
        let form = "username=".appending(email).appending("&password=").appending(password).appending("&grant_type=password")
        PostRequest().urlencodedPost(postUrl: Constants.API.login, form: form, completionHandler: { (success) -> Void in
            print("Finished")
        })
    }
    

}

