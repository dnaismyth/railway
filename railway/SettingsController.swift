//
//  SettingsController.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-01-28.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit


class SettingsController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    let userDefaults = Foundation.UserDefaults.standard
    var selectedLanguage : String?
    var receieveEmailUpdates : Bool?
    var pickerData: [String] = [String]()
    var languageToBeUpdated : Bool = false

    
    @IBOutlet weak var signoutCell: UITableViewCell!
    @IBOutlet weak var languagePicker: UIPickerView!
    @IBOutlet weak var languageSelected: UILabel!
    @IBOutlet weak var emailUpdateSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.languagePicker.delegate = self
        self.languagePicker.dataSource = self
        pickerData = ["English", "French"]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("section: \(indexPath.section)")
        print("row: \(indexPath.row)")
        let cell = tableView.cellForRow(at: indexPath)
        let identifier : String = cell!.reuseIdentifier!
        print("Identifier is \(identifier)")
        switch(identifier){
            case "languageCell" :
                languageToBeUpdated = true      // if cell has been touch, we need to flag this to be updated
                showLanguagePicker()
                break
            case "changePasswordCell" :
                goToUpdatePasswordView()
                break
            case "signoutCell"  :
                logoutUser()
                break
            default :
                self.checkIfDirty()
                break
        }
        
    }
    
    // Check if language should be updated
    private func checkIfDirty(){
        if(languageToBeUpdated == true){
            self.savePickerChoiceAndRestoreLanguageCell()
            languageToBeUpdated = false
        }
    }
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print(pickerData[row])
        selectedLanguage = pickerData[row]
        return pickerData[row]
    }
    
    // Allow user to update their preferred language key
    private func updateUserLanguageKey(langKey : String){
        let token : String = userDefaults.string(forKey: "access_token")!
        var params : [String : AnyObject] = [:]
        params["value"] = langKey as AnyObject?
        PutRequest().jsonPut(postUrl: Constants.API.updateLanguageKey, token: token, body: params) { (dictionary) in
            print(dictionary)
            self.languageToBeUpdated = false        // flag as no longer needing to be updated
        }
    }
    
    // Toggle on/off user email preferences
    private func updateUserEmailPreferences(recieveEmailUpdates : Bool){
        let token : String = userDefaults.string(forKey: "access_token")!
        var params : [String : AnyObject] = [:]
        params["value"] = receieveEmailUpdates as AnyObject?
        PutRequest().jsonPut(postUrl: Constants.API.updateEmailPrefs, token: token, body: params) { (dictionary) in
            print(dictionary)
            self.emailUpdateSwitch.isEnabled = true  // re-enable the switch after api call is complete
        }
    }
    
    // Logout user
    private func logoutUser(){
        let token : String = userDefaults.string(forKey: "access_token")!
        let params : [String : AnyObject] = [:]
        PutRequest().jsonPut(postUrl: Constants.API.logout, token: token, body: params) { (dictionary) in
            // Remove user defaults
            let appDomain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
            // Dismiss view
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func showLanguagePicker(){
        print("Showing language picker")
        languageSelected.isHidden = true
        languagePicker.isHidden = false
    }
    
    private func savePickerChoiceAndRestoreLanguageCell(){
        if(selectedLanguage != nil){
            let isoCode : String = getLanguageISO(language: selectedLanguage!)
            languageSelected.text = selectedLanguage!
            updateUserLanguageKey(langKey: isoCode)
        }
        
        languagePicker.isHidden = true
        languageSelected.isHidden = false
        
    }
    
    @IBAction func switchListener(_ sender: UISwitch) {
        if emailUpdateSwitch.isOn {
            receieveEmailUpdates = true
            emailUpdateSwitch.isEnabled = false // disable switch while updating
            self.updateUserEmailPreferences(recieveEmailUpdates: true)
        }
        else {
            receieveEmailUpdates = false
            emailUpdateSwitch.isEnabled = false // disable switch while updating
            self.updateUserEmailPreferences(recieveEmailUpdates: false)
        }
    }
    
    // View Update Password Settings
    private func goToUpdatePasswordView(){
        print("Going to update password view")
        let updatePasswordSettings = self.storyboard?.instantiateViewController(withIdentifier: "updatePasswordSettings") as! UpdatePasswordViewController

        self.navigationController?.pushViewController(updatePasswordSettings, animated: true)
    }
    
    
    // Return ISO code for language from the selected choice
    private func getLanguageISO(language : String) -> String{
        switch(language){
            case "English" :
                return "EN"
            case "French" :
                return  "FR"
            default :
                return "EN"
        }
    }
    
}
