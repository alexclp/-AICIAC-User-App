//
//  Room.swift
//  [AICIAC]User-App
//
//  Created by Alexandru Clapa on 03/03/2018.
//  Copyright © 2018 Alexandru Clapa. All rights reserved.
//

import UIKit

class Room: NSObject {
	var id: Int
	var name: String
	var floorNumber: Int
	
	init(id: Int = 0, name: String = "", floorNumber: Int = 0) {
		self.id = id
		self.name = name
		self.floorNumber = floorNumber
	}
}
