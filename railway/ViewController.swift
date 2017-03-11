//
//  ViewController.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-01-28.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit
import FirebaseDatabase


class ViewController: UIViewController{
    
    let userDefaults = Foundation.UserDefaults.standard

    //MARK: Properties
    @IBOutlet weak var emailLogin: UITextField!
    @IBOutlet weak var passwordLogin: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var LogoImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up email textfield
        let emailIcon : UIImageView = UIImageView(image: UIImage(named: "emailIcon"))
        emailIcon.frame = CGRect(x: 8, y: 0, width: 20, height: 20)
        let emailPadding : UIView = UIView(frame: CGRect(x:0, y:0, width: 28, height: 20))
        emailPadding.addSubview(emailIcon)
        emailLogin.leftView = emailPadding
        emailLogin.leftViewMode = UITextFieldViewMode.always
        emailLogin.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName : UIColor(red:1.00, green:1.00,blue:1.00, alpha:0.7)])
        //emailLogin.addRadius()
        
        // Set up Password textfield
        let passwordIcon : UIImageView = UIImageView(image: UIImage(named: "passwordIcon"))
        passwordIcon.frame = CGRect(x: 8, y: 0, width: 20, height: 20)
        let passwordPadding : UIView = UIView(frame: CGRect(x:0, y:0, width: 28, height: 20))
        passwordPadding.addSubview(passwordIcon)
        passwordLogin.leftView = passwordPadding
        passwordLogin.leftViewMode = UITextFieldViewMode.always
        passwordLogin.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.7)])
        //passwordLogin.addRadius()
        
        //LoginButton.addRadius()
        LoginButton.addShadowView()
        //LogoImage.addShadowView()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("View appearing")
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Check that email input is provided
    func validateEmail() -> String {
        let email: String! = self.emailLogin.text
        if(email.characters.count <= 0){
            self.showInvalidAlert(alertTitle:"Error", alertMessage:"Please enter valid credentials.")
        }
        return email;
    }
    
    // Check that password input is provided
    func validatePassword() -> String {
        let password: String! = self.passwordLogin.text
        if(password.characters.count <= 0){
            self.showInvalidAlert(alertTitle:"Error", alertMessage:"Please enter valid credentials.")
        }
        return password;
    }
    
    private func showInvalidAlert(alertTitle: String, alertMessage: String){
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        let email = validateEmail()
        let password = validatePassword()
        let form = "username=".appending(email).appending("&password=").appending(password).appending("&grant_type=password")
        PostRequest().urlencodedPost(postUrl: Constants.API.login, form: form, completionHandler: { (dictionary) -> Void in
            OperationQueue.main.addOperation{
                if(dictionary["access_token"] != nil){
                    self.storeLoginResponse(response: dictionary)
                    FirebaseAuthentication().getFirebaseToken(token: "Bearer ".appending(dictionary["access_token"] as! String))
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier :"tabBarView")
                    self.present(viewController, animated: true)
                } else {
                    self.showInvalidAlert(alertTitle: "Error Signing In", alertMessage: "The e-mail or password is incorrect.")
                }
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

