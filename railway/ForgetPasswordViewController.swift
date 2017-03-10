//
//  ForgetPasswordViewController.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-03-09.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class ForgetPasswordViewController: UIViewController {

    @IBOutlet weak var emailInput: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func sendPasswordResetEmail(_ sender: UIButton) {
        let email : String = validateEmail()
        self.sendPasswordResetEmailRequest(email: email)
    }
    
    // Check that email input is provided
    func validateEmail() -> String {
        let email: String! = self.emailInput.text
        if(email.characters.count <= 0){
            self.showAlert(alertTitle:"Error", alertMessage:"You must provide en e-mail address.")
        }
        return email;
    }
    
    private func showAlert(alertTitle: String, alertMessage: String){
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func sendPasswordResetEmailRequest(email : String){
        var params : [String : AnyObject] = [:]
        params["value"] = email as AnyObject
        PostRequest().jsonPost(postUrl: Constants.API.requestPasswordReset, token: Constants.TOKEN.basic_token, body: params) { (dictionary) in
            OperationQueue.main.addOperation{
                self.showAlert(alertTitle: "Email Sent!", alertMessage: "Please check your e-mail to complete the password reset process.")
            }
        }
    }

}
