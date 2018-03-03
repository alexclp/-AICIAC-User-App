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
	
	func getCurrentPosition() {
		requestScan { (success) in
			if success == true {
				print("REQUEST SCAN --- SUCCESS")
				sleep(5)
				print("WOKE UP --- SUCCESS")
				self.getMeasurements(completion: { (response, json) in
					if response == true {
						print("WILL TRY TO DETERMINE POSITION --- SUCCESS @ get measurements")
						let urlString = "https://nav-backend.herokuapp.com/determinePosition"
						guard let json = json else { return }
						let params = ["measurements": json]
						HTTPClient.shared.request(urlString: urlString, method: "POST", parameters: params, completion: { (response, data) in
							print(response)
							guard let data = data else { return }
							do {
								if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
									print(json)
									
									self.deleteAllTempMeasurements(completion: { (success) in
										if success == true {
											print("DELETED DATA")
										}
									})
								}
							} catch {
								print(error.localizedDescription)
							}
						})
					} else {
						print("FAILED TO GET MEASUREMENTS")
					}
				})
			}
		}
	}
	
	// MARK: - Private methods
	
	private func requestScan(completion: @escaping (Bool) -> Void) {
		let urlString = "https://scanner-on-off.herokuapp.com"
		let params = ["locationID": 0,
					  "roomID": 0,
					  "shouldScan": 1,
					  "storeData":  0]
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
