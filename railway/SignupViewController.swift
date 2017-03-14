//
//  SignupViewController.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-02-22.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
    
    //MARK: Properties
    let userDefaults = Foundation.UserDefaults.standard
    typealias FinishedStoringResponse = () -> ()

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var RegisterButton: UIButton!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Placeholder attributes
        
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName : UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.7)])
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName : UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.7)])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.7)])
        
        // Email Setup
        let emailIcon : UIImageView = UIImageView(image: UIImage(named: "emailIcon")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate))
        emailIcon.tintColor = Constants.COLOR.midnight
        emailIcon.frame = CGRect(x: 8, y: 0, width: 20, height: 20)
        let emailPadding : UIView = UIView(frame: CGRect(x:0, y:0, width: 28, height: 20))
        emailPadding.addSubview(emailIcon)
        emailTextField.leftView = emailPadding
        emailTextField.leftViewMode = UITextFieldViewMode.always
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
        
        // Password Setup
        let passwordIcon : UIImageView = UIImageView(image: UIImage(named: "passwordIcon")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate))
        passwordIcon.tintColor = Constants.COLOR.midnight
        passwordIcon.frame = CGRect(x: 8, y: 0, width: 20, height: 20)
        let passwordPadding : UIView = UIView(frame: CGRect(x:0, y:0, width: 28, height: 20))
        passwordPadding.addSubview(passwordIcon)
        passwordTextField.leftView = passwordPadding
        passwordTextField.leftViewMode = UITextFieldViewMode.always
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
        
        // Name Setup
        let nameIcon : UIImageView = UIImageView(image: UIImage(named: "nameIcon")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate))
        nameIcon.tintColor = Constants.COLOR.midnight
        nameIcon.frame = CGRect(x: 8, y: 0, width: 20, height: 20)
        let namePadding : UIView = UIView(frame: CGRect(x:0, y:0, width: 28, height: 20))
        namePadding.addSubview(nameIcon)
        nameTextField.leftView = namePadding
        nameTextField.leftViewMode = UITextFieldViewMode.always
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName : UIColor.lightGray])

        self.hideKeyboardWhenTappedAround()
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
        let email: String! = self.emailTextField.text
        if(email.characters.count <= 0){
            self.showInvalidAlert(alertTitle:"Error", alertMessage:"You must provide en e-mail address.")
        }
        return email;
    }
    
    // Validate that a name has been provided
    func validateName() -> String {
        let name : String! = self.nameTextField.text
        if(name.characters.count <= 0){
            self.showInvalidAlert(alertTitle:"Error", alertMessage:"You must provide a name.")
        }
        return name;
    }
    
    // Check that password input is provided
    func validatePassword() -> String {
        let password: String! = self.passwordTextField.text
        if(password.characters.count < 5){
            self.showInvalidAlert(alertTitle:"Error", alertMessage:"Password must be a minimum of 5 characters.")
        }
        return password;
    }
    
    private func showInvalidAlert(alertTitle: String, alertMessage: String){
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func registerButton(_ sender: UIButton) {
        let name = self.validateName()
        let email = self.validateEmail()
        let password = self.validatePassword()
        
        let data : [String:AnyObject] = [
            "name" : name as AnyObject,
            "email": email as AnyObject,
            "password" : password as AnyObject
        ]
        
        PostRequest().jsonPost(postUrl: Constants.API.signup, token: Constants.TOKEN.basic_token, body: data, completionHandler: { (dictionary) -> Void in
                OperationQueue.main.addOperation{
                    print(dictionary)
                    let response : [String:AnyObject] = dictionary["data"] as! [String:AnyObject]
                    if(response["access_token"] != nil){
                        self.storeSignupResponse(response: response as NSDictionary, completed :{
                            () -> () in
                            self.saveUserResourceTokens() // save the device token on registration
                            FirebaseAuthentication().getFirebaseToken(token: "Bearer ".appending(dictionary["access_token"] as! String))
                        })
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier :"tabBarView")
                        self.present(viewController, animated: true)
                    } else {
                        self.showInvalidAlert(alertTitle: "Error Signing In", alertMessage: "The e-mail address is already in use.")
                    }
                }
        })
        
        
    }
    
    private func storeSignupResponse(response : NSDictionary, completed : FinishedStoringResponse){
        let access_token = "Bearer ".appending(response["access_token"] as! String)
        let refresh_token = response["refresh_token"] as! String
        let expires_in = response["expires_in"]
        userDefaults.set( access_token , forKey: "access_token")
        userDefaults.set( refresh_token, forKey: "refresh_token")
        userDefaults.set( expires_in, forKey:"expires_in")
        completed()
    }
    
    
    // Save the user device token and FCM refresh token
    private func saveUserResourceTokens(){
        let device_token = userDefaults.string(forKey: "device_token")
        let fcm_token = userDefaults.string(forKey: "fcm_token")
        let access_token = userDefaults.string(forKey: "access_token")
        let data : [String:AnyObject] = [
            "deviceToken" : device_token as AnyObject,
            "fcmToken" : fcm_token as AnyObject,
            "platform" : Constants.PLATFORM.apple as AnyObject
        ]
        PutRequest().jsonPut(postUrl: Constants.API.storeDeviceToken, token: access_token!, body: data, completionHandler: { (dictionary) -> Void in
            OperationQueue.main.addOperation {
                print(dictionary)
            }
        })
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
