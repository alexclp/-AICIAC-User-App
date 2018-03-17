//
//  ARDataHelper.swift
//  [AICIAC]User-App
//
//  Created by Alexandru Clapa on 17/03/2018.
//  Copyright © 2018 Alexandru Clapa. All rights reserved.
//

import UIKit

class ARDataHelper: NSObject {
	static let shared = ARDataHelper()
	
	private override init() { }
	
	func closestLocations(currentLocation: Location, completion: @escaping (Bool, [String: Any]?) -> Void) {
		let urlString = "https://wifi-nav-api.herokuapp.com/closestLocation"
		let params = ["locationID": currentLocation.id]
		HTTPClient.shared.request(urlString: urlString, method: "POST", parameters: params) { (response, data) in
			if response == true {
				guard let data = data else { return }
				do {
					if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
						completion(true, json)
					}
				} catch {
					print(error.localizedDescription)
					completion(false, nil)
				}
			}
		}
	}
}
