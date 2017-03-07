//
//  UpdatePasswordViewController.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-03-06.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation
import UIKit

class UpdatePasswordViewController : UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var verifyPasswordField: UITextField!
    let userDefaults = Foundation.UserDefaults.standard
    typealias FinishedStoringResponse = () -> ()

    let minPassLength : Int = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    
    // On button select, update the users password
    @IBAction func updateButton(_ sender: UIButton) {
        if(verifyPassword(newPass: newPasswordField.text!, verifyPass: verifyPasswordField.text!)){
            let token : String = userDefaults.string(forKey: "access_token")!
            print("Token value is: \(token)")
            var params : [String : AnyObject] = [:]
            params["password"] = newPasswordField.text! as AnyObject?
            PutRequest().jsonPut(postUrl: Constants.API.updatePassword, token: token, body: params, completionHandler: { (dictionary) in
                print(dictionary)
                if(dictionary["token"] != nil){
                    self.storeUpdatePasswordResponse(response: dictionary["token"] as! NSDictionary, completionHandler: {
                        self.showPasswordUpdatedAlert(alertTitle: "Password Changed", alertMessage: "Your password has been updated successfully.  Please use these credentials the next time you login.")
                    })
                }
            })
        }
    }
    
    // Return back to settings view
    private func returnToSettingsView(){
        print("Returning to settings view.")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "settingsView") as! SettingsController
        self.present(vc, animated: true, completion: nil)
    }
    
    private func storeUpdatePasswordResponse(response : NSDictionary, completionHandler: @escaping FinishedStoringResponse ){
        let access_token = "Bearer ".appending(response["access_token"] as! String)
        let refresh_token = response["refresh_token"] as! String
        let expires_in = response["expires_in"]
        userDefaults.set( access_token , forKey: "access_token")
        userDefaults.set( refresh_token, forKey: "refresh_token")
        userDefaults.set( expires_in, forKey:"expires_in")
        completionHandler()
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
    
    // Verify the password contents to check validity
    private func verifyPassword(newPass : String, verifyPass : String) -> Bool{
        if(newPass != verifyPass){
            showAlert(alertTitle: "Invalid Password", alertMessage: "Passwords must match.")
            return false
        } else if (newPass.characters.count < minPassLength || verifyPass.characters.count < minPassLength){
            showAlert(alertTitle: "Invalid Password", alertMessage: "Password must be at least six characters.")
            return false
        }
        return true
    }
    
    // Show alerts if passwords are invalid
    private func showAlert(alertTitle: String, alertMessage: String){
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showPasswordUpdatedAlert(alertTitle: String, alertMessage: String){
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.returnToSettingsView()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}
