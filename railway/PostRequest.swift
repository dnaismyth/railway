//
//  PostRequest.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-02-11.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//
import Foundation
class PostRequest{
    
    private let baseUrl = "http://localhost:8080/"
    
    public func httpPost(postUrl: String, form: String){
        // Build full URL with base
        let formatUrl = baseUrl.appending(postUrl)
        print(formatUrl)
        let url = URL(string:formatUrl)!
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic cmFpbHdheXNlcnZpY2UtaW9zOmtKRktDdDJFenNXM2oyYTQ=", forHTTPHeaderField: "Authorization")
        request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        
        request.httpBody = form.data(using: .utf8)
        
        
        //create dataTask using the session object to send data to the server
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
    }
}
