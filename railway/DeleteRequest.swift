//
//  DeleteRequest.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-02-18.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation

class DeleteRequest {
    
    typealias CompletionHandler = (NSDictionary) -> ()
    
    public func HTTPDelete(getUrl : String, token: String, completionHandler: @escaping (CompletionHandler))  {
        
        let formatUrl = Constants.API.baseUrl.appending(getUrl)
        print(formatUrl)
        let url = URL(string:formatUrl)!
        var request = URLRequest(url: url)
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            guard error == nil else {
                print(error ?? "Error sending get request.")
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            completionHandler(json as! NSDictionary)
        }
        
        task.resume()
    }
}
