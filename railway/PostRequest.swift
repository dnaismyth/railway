//
//  PostRequest.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-02-11.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//
import Foundation
class PostRequest : NSObject, NSURLConnectionDataDelegate {
    
    typealias CompletionHandler = (NSDictionary) -> ()

    public func urlencodedPost(postUrl: String, form: String, completionHandler: @escaping (CompletionHandler)){
        // Build full URL with base
        let formatUrl = Constants.API.baseUrl.appending(postUrl)
        print(formatUrl)
        let url = URL(string:formatUrl)!
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(Constants.TOKEN.basic_token, forHTTPHeaderField: "Authorization")
        request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        
        request.httpBody = form.data(using: .utf8)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data,response,error in
            if error != nil{
                print(error?.localizedDescription ?? "Error")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                if json != nil {
                    completionHandler(json!)
                }
            } catch let error as NSError {
                completionHandler([String: String]() as NSDictionary)
                print(error)
            }
        }
        task.resume()
    }
}
