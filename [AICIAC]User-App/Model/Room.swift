//
//  Room.swift
//  [AICIAC]User-App
//
//  Created by Alexandru Clapa on 03/03/2018.
//  Copyright © 2018 Alexandru Clapa. All rights reserved.
//

import UIKit

class Room: NSObject {
	var name: String
	var floorNumber: Int
	
	init(name: String, floorNumber: Int) {
		self.name = name
		self.floorNumber = floorNumber
	}
}
