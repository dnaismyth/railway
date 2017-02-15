//
//  PostRequest.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-02-11.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//
import Foundation
class PostRequest : NSObject, NSURLConnectionDataDelegate {
    
    let userDefaults = Foundation.UserDefaults.standard
    typealias CompletionHandler = (Bool) -> ()

    public func urlencodedPost(postUrl: String, form: String, completionHandler: @escaping (CompletionHandler)){
        // Build full URL with base
        let formatUrl = Constants.API.baseUrl.appending(postUrl)
        print(formatUrl)
        let url = URL(string:formatUrl)!
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic cmFpbHdheXNlcnZpY2UtaW9zOmtKRktDdDJFenNXM2oyYTQ=", forHTTPHeaderField: "Authorization")
        request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        
        request.httpBody = form.data(using: .utf8)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data,response,error in
            if error != nil{
                print(error?.localizedDescription ?? "Error")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                if let parseJSON = json {
                    let resultValue:String = parseJSON["access_token"] as! String;
                    print("result: \(resultValue)")
                    print(parseJSON)
                    self.storeLoginResponse(response: json!)
                    completionHandler(true)
                }
            } catch let error as NSError {
                completionHandler(false)
                print(error)
            }
        }
        task.resume()
    }
    
    private func storeLoginResponse(response : NSDictionary){
        let access_token = "Bearer ".appending(response["access_token"] as! String)
        let refresh_token = response["refresh_token"] as! String
        print(access_token)
        print(refresh_token)
        userDefaults.set( access_token , forKey: "access_token")
        userDefaults.set( refresh_token, forKey: "refresh_token")
    }
}
