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
	
	init(x: Double, y: Double, lat: Double, long: Double, id: Int, roomID: Int, standardHeight: Double, standardWidth: Double) {
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
