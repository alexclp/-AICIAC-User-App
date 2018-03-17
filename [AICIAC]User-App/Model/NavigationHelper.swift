//
//  NavigationHelper.swift
//  [AICIAC]User-App
//
//  Created by Alexandru Clapa on 02/03/2018.
//  Copyright © 2018 Alexandru Clapa. All rights reserved.
//

import UIKit

class NavigationHelper: NSObject {
	static let shared = NavigationHelper()
	
	private override init() { }
	
	func getCurrentPosition(completion: @escaping (Bool, [String: Any]?) -> Void) {
		requestScan { (success) in
			if success == true {
				print("REQUEST SCAN --- SUCCESS")
				sleep(12)
				print("WOKE UP --- SUCCESS")
				self.getMeasurements(completion: { (response, json) in
					if response == true {
						print("WILL TRY TO DETERMINE POSITION --- SUCCESS @ get measurements")
//						let urlString = "https://nav-backend.herokuapp.com/determinePosition"
						let urlString = "http://10.40.254.127:8080/determinePosition"
						guard let json = json else { return }
						let params = ["measurements": json]
						HTTPClient.shared.request(urlString: urlString, method: "POST", parameters: params, completion: { (response, data) in
							print(response)
							guard let data = data else { completion(false, nil); return }
							do {
								if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
									print(json)
									completion(true, json)
									
									self.deleteAllTempMeasurements(completion: { (success) in
										if success == true {
											print("DELETED DATA")
										}
									})
								}
							} catch {
								print(error.localizedDescription)
								completion(false, nil)
							}
						})
					} else {
						print("FAILED TO GET MEASUREMENTS")
						completion(false, nil)
					}
				})
			}
		}
	}
	
	func getRoute(from start: Location, to finish: Location, completion: @escaping (Bool, [Int]?) -> Void) {
//		let urlString = "https://nav-backend.herokuapp.com/calculateRoute"
		let urlString = "http://10.40.254.127:8080/calculateRoute"
		let params = ["startLocationID": start.id,
					  "finishLocationID": finish.id]
		HTTPClient.shared.request(urlString: urlString, method: "POST", parameters: params) { (response, data) in
			if response == true {
				guard let data = data else { return }
				do {
					if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
						if let path = json["path"] as? [Int] {
							print(path)
							completion(true, path)
						}
					}
				} catch {
					print(error.localizedDescription)
					completion(false, nil)
				}
			}
		}
	}
	
	func getConnectingLocation(in room: Room, completion: @escaping (Bool, Location?) -> Void) {
		let urlString = "https://wifi-nav-api.herokuapp.com/rooms/connectingLocation/\(room.id)"
		HTTPClient.shared.request(urlString: urlString, method: "GET", parameters: nil) { (success, data) in
			if success == true {
				do {
					guard let data = data else { return }
					if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
						if let x = json["x"] as? Double, let y = json["y"] as? Double, let lat = json["latitude"] as? Double, let longitude = json["longitude"] as? Double, let id = json["id"] as? Int, let standardWidth = json["standardWidth"] as? Double, let standardHeight = json["standardHeight"] as? Double, let roomID = json["roomID"] as? Int {
							completion(true, Location.init(x: x, y: y, lat: lat, long: longitude, id: id, roomID: roomID, standardHeight: standardHeight, standardWidth: standardWidth))
						} else {
							completion(false, nil)
						}
					}
				} catch {
					print(error.localizedDescription)
					completion(false, nil)
				}
			}
		}
	}
	
	func getLocation(with id: Int, completion: @escaping (Bool, Location?) -> Void) {
		let urlString = "https://wifi-nav-api.herokuapp.com/locations/\(id)"
		HTTPClient.shared.request(urlString: urlString, method: "GET", parameters: nil) { (success, data) in
			if success == true {
				do {
					guard let data = data else { return }
					if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
						if let x = json["x"] as? Double, let y = json["y"] as? Double, let lat = json["latitude"] as? Double, let longitude = json["longitude"] as? Double, let id = json["id"] as? Int, let standardWidth = json["standardWidth"] as? Double, let standardHeight = json["standardHeight"] as? Double, let roomID = json["roomID"] as? Int {
							completion(true, Location.init(x: x, y: y, lat: lat, long: longitude, id: id, roomID: roomID, standardHeight: standardHeight, standardWidth: standardWidth))
						}
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
	
	// MARK: - Private methods
	
	private func requestScan(completion: @escaping (Bool) -> Void) {
		let urlString = "https://scanner-on-off.herokuapp.com"
		let params = ["locationID": 0,
					  "roomID": 0,
					  "shouldScan": 1,
					  "storeData": 0]
			as [String: Any]
		HTTPClient.shared.request(urlString: urlString + "/scanSwitch/1", method: "PATCH", parameters: params) { (success, responseJSON) in
			if success == true {
				print("Successfully turned scanner on")
				completion(true)
			} else {
				print("Failed to turn scanner on")
				completion(false)
			}
		}
	}
	
	private func getMeasurements(completion: @escaping (Bool, [[String: Any]]?) -> Void) {
		let urlString = "https://scanner-on-off.herokuapp.com"
		HTTPClient.shared.request(urlString: urlString + "/measurements", method: "GET", parameters: nil) { (success, data) in
			if success == true {
				do {
					guard let data = data else { return }
					if let json = try JSONSerialization.jsonObject(with: data, options: []) as?[[String: Any]] {
						completion(true, json)
					}
				} catch {
					print(error)
				}
			} else {
				completion(false, nil)
			}
		}
	}
	
	private func deleteAllTempMeasurements(completion: @escaping (Bool) -> Void) {
		let urlString = "https://scanner-on-off.herokuapp.com/measurements"
		HTTPClient.shared.request(urlString: urlString, method: "DELETE", parameters: nil) { (success, data) in
			completion(success)
		}
	}
}
