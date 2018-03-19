//
//  IndoorLocationManager.swift
//  [AICIAC]User-App
//
//  Created by Alexandru Clapa on 19/03/2018.
//  Copyright © 2018 Alexandru Clapa. All rights reserved.
//

import UIKit
import CoreLocation

protocol IndoorLocationManagerDelegate {
	func locationManager(_ manager: IndoorLocationManager, didUpdateLocation location: Location)
}

class IndoorLocationManager: NSObject {
	var delegate: IndoorLocationManagerDelegate?
	
	private var locationUpdateTimer = Timer.init()
	
	func startUpdatingLocation() {
		locationUpdateTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.determinePosition), userInfo: nil, repeats: true)
	}
	
	func stopUpdatingLocation() {
		locationUpdateTimer.invalidate()
	}
	
	@objc private func determinePosition() {
		NavigationHelper.shared.getCurrentPosition { (success, data) in
			if success == true {
				guard let data = data else { return }
				guard let x = data["x"] as? Double else { print("Failed to get x"); return }
				guard let y = data["y"] as? Double else { print("Faield to get y"); return }
				guard let standardHeight = data["standardHeight"] as? Double else { print("Failed to get standard height"); return }
				guard let standardWidth = data["standardWidth"] as? Double else { print("Failed standard width"); return }
				guard let lat = data["latitude"] as? Double else { print("Failed to get lat"); return }
				guard let long = data["longitude"] as? Double else { print("Failed to get long"); return }
				guard let roomID = data["roomID"] as? Int else { print("Failed to get room ID"); return }
				guard let id = data["id"] as? Int else { print("Failed to get id"); return }
				guard let floorNumber = data["floorNumber"] as? Int else { print("Failed to get floor number"); return }
				
				let location = Location.init(x: x, y: y, lat: lat, long: long, id: id, roomID: roomID, standardHeight: standardHeight, standardWidth: standardWidth, floorNumber: floorNumber)
				self.delegate?.locationManager(self, didUpdateLocation: location)
			}
		}
	}
}
