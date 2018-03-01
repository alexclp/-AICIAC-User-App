//
//  HTTPClient.swift
//  [AICIAC]Admin-App
//
//  Created by Alexandru Clapa on 29/01/2018.
//  Copyright © 2018 Alexandru Clapa. All rights reserved.
//

import UIKit

class HTTPClient: NSObject {
	static let shared = HTTPClient()
	
	private override init() { }
	
	func request(urlString: String, method: String, parameters: [String: Any]?, completion: @escaping (Bool, Data?) -> Void) {
		let url = URL(string: urlString)
		var urlRequest = URLRequest(url: url!)
		urlRequest.httpMethod = method
		urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
		if let paramString =  parameters?.jsonString() {
			urlRequest.httpBody = paramString.data(using: .utf8)
		}
		
		let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
			guard error == nil else {
				print(error!)
				completion(false, nil)
				return
			}
			
			guard let data = data else {
				print("Data is empty")
				completion(false, nil)
				return
			}
			
			guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
				completion(false, nil)
				return
			}
			
			if statusCode != 200 {
				completion(false, nil)
				return
			}
			
			completion(true, data)
		})
		
		task.resume()
	}
}

