//
//  SearchHelper.swift
//  [AICIAC]User-App
//
//  Created by Alexandru Clapa on 03/03/2018.
//  Copyright © 2018 Alexandru Clapa. All rights reserved.
//

import UIKit

class SearchHelper: NSObject {
	static let shared = SearchHelper()
	
	private override init() { }
	
	private let baseURL = "https://wifi-nav-api.herokuapp.com"
	
	func searchRoom(query: String, completion: @escaping (Bool, [Room]?) -> Void) {
		let params = ["query": query]
		
		HTTPClient.shared.request(urlString: "\(baseURL)/rooms/search", method: "POST", parameters: params) { (response, data) in
			
			if response == true {
				guard let data = data else { return }
				
				do {
					if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
						
						var rooms = [Room]()
						
						for element in json {
							if let name = element["name"] as? String, let floor = element["floorNumber"] as? Int, let id = element["id"] as? Int {
								rooms.append(Room.init(id: id, name: name, floorNumber: floor))
							}
						}
						completion(true, rooms)
					}
				} catch {
					print(error.localizedDescription)
					completion(false, nil)
				}
			} else {
				completion(false, nil)
			}
		}
	}
}
