//
//  GetRequest.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-02-12.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation

class GetRequest{
    
    public func HTTPGet(getUrl : String, token: String)  {
        
        let formatUrl = Constants.API.baseUrl.appending(getUrl)
        print(formatUrl)
        let url = URL(string:formatUrl)!
        var request = URLRequest(url: url)
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
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
            print(json)
        }
        
        task.resume()
    }
}
