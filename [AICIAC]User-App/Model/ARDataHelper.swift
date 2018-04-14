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
	
	func closestLocations(currentLocation: Location, completion: @escaping (Bool, [String: Location]?) -> Void) {
		let urlString = "https://wifi-nav-api.herokuapp.com/closestLocations"
		let params = ["locationID": currentLocation.id]
		HTTPClient.shared.request(urlString: urlString, method: "POST", parameters: params) { (response, data) in
			if response == true {
				guard let data = data else { return }
				do {
					if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
						var toReturn = [String: Location]()
						for (key, object) in json {
							if let object = object as? [String: Any] {
								let location = Location.init()
								location.id = object["id"] as! Int
								location.lat = object["latitude"] as! Double
								location.long = object["longitude"] as! Double
								location.x = object["x"] as! Double
								location.y = object["y"] as! Double
								location.standardWidth = object["standardWidth"] as! Double
								location.standardHeight = object["standardHeight"] as! Double
								location.roomID = object["roomID"] as! Int
								toReturn[key] = location
							}
						}
						print(toReturn)
						completion(true, toReturn)
					} else {
						completion(false, nil)
					}
				} catch {
					print(error.localizedDescription)
					completion(false, nil)
				}
			}
		}
	}
	
	func getTimetableImageFor(roomName: String, completion: @escaping (Bool, UIImage?) -> Void) {
		let url = "https://4582f1d2.ngrok.io/timetable/\(roomName)"
		HTTPClient.shared.request(urlString: url, method: "GET", parameters: nil) { (response, data) in
			if response == true {
				guard let data = data else { return }
				if let image = UIImage(data: data) {
					completion(true, image)
				} else {
					completion(false, nil)
				}
			} else {
				completion(false, nil)
			}
		}
	}
	
	func getComputersAvailability(roomName: String, completion: @escaping (Bool, UIImage?) -> Void) {
		let url = "/pcfree/\(roomName)"
		HTTPClient.shared.request(urlString: url, method: "GET", parameters: nil) { (response, data) in
			if response == true {
				guard let data = data else { return }
				if let image = UIImage(data: data) {
					completion(true, image)
				} else {
					completion(false, nil)
				}
			} else {
				completion(false, nil)
			}
		}
	}
}
