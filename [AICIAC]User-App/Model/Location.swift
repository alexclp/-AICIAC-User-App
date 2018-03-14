//
//  Location.swift
//  [AICIAC]User-App
//
//  Created by Alexandru Clapa on 03/03/2018.
//  Copyright © 2018 Alexandru Clapa. All rights reserved.
//

import UIKit

class Location: NSObject {
	var x: Double
	var y: Double
	var lat: Double
	var long: Double
	var id: Int
	var roomID: Int
	var standardHeight: Double
	var standardWidth: Double
	var view: UIView? = nil
	
	public override var description: String {
		return "Location: {x = \(x), y = \(y), lat = \(lat), long = \(long)"
	}
	
	init(x: Double = 0.0, y: Double = 0.0, lat: Double = 0.0, long: Double = 0.0, id: Int = 0, roomID: Int = 0, standardHeight: Double = 0.0, standardWidth: Double = 0.0) {
		self.x = x
		self.y = y
		self.lat = lat
		self.long = long
		self.id = id
		self.roomID = roomID
		self.standardHeight = standardHeight
		self.standardWidth = standardWidth
	}
}
