//
//  FirebaseAuthentication.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-03-02.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation
import FirebaseAuth

class FirebaseAuthentication {
    
    func signInWithCustomToken(customToken : String){
        FIRAuth.auth()?.signIn(withCustomToken: customToken) { (user, error) in
            if((user) != nil){
                print(user as Any)
            } else {
                print(error as Any)
            }
        }
    }
    
    func fireBaseSignOut(){
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    public func getFirebaseToken(token : String){
        GetRequest().HTTPGet(getUrl: Constants.API.getFirebaseToken, token: token, completionHandler : { (dictionary) -> Void in
            OperationQueue.main.addOperation{
                let firebaseToken : String = dictionary["data"] as! String!
                print("Firebase token is: \(firebaseToken)")
                self.signInWithCustomToken(customToken: firebaseToken)
            }
        })
    }
}
