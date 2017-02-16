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
        PostRequest().urlencodedPost(postUrl: Constants.API.login, form: form, completionHandler: { (dictionary) -> Void in
            if(dictionary["access_token"] != nil){
                OperationQueue.main.addOperation {
                    self.storeLoginResponse(response: dictionary)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier :"crossingsView")
                    self.present(viewController, animated: true)
                }
            } else {
                // Show invalid credentials screen
                print("Not finished")
            }
        })
    }
    
    private func storeLoginResponse(response : NSDictionary){
        let access_token = "Bearer ".appending(response["access_token"] as! String)
        let refresh_token = response["refresh_token"] as! String
        let expires_in = response["expires_in"]
        userDefaults.set( access_token , forKey: "access_token")
        userDefaults.set( refresh_token, forKey: "refresh_token")
        userDefaults.set( expires_in, forKey:"expires_in")
    }

}

