//
//  Utils.swift
//  [AICIAC]User-App
//
//  Created by Alexandru Clapa on 05/03/2018.
//  Copyright © 2018 Alexandru Clapa. All rights reserved.
//

import UIKit

class Utils: NSObject {
	static let shared = Utils()
	
	private override init() { }
	
	static func interpolatePointToCurrentSize(point: CGPoint, from standardSize: CGSize, in view: UIView) -> CGPoint? {
		//		guard let currentSize = (UIApplication.shared.delegate as? AppDelegate)?.window?.bounds.size else { return nil }
		let currentSize = view.bounds.size
		return CGPoint(
			x: point.x * currentSize.width / standardSize.width,
			y: point.y * currentSize.height / standardSize.height
		)
	}
	
	static func degreesToRadians(degrees: Double) -> Double {
		return degrees * .pi / 180.0
	}
	
	static func radiansToDegrees(radians: Double) -> Double {
		return radians * 180.0 / .pi
	}
	
	// https://stackoverflow.com/questions/26998029/calculating-bearing-between-two-cllocation-points-in-swift
	
	func getBearingBetweenTwoPoints(point1: Location, point2: Location) -> Double {
		let lat1 = Utils.degreesToRadians(degrees: point1.lat)
		let lon1 = Utils.degreesToRadians(degrees: point1.long)
		
		let lat2 = Utils.degreesToRadians(degrees: point2.lat)
		let lon2 = Utils.degreesToRadians(degrees: point2.long)
		
		let dLon = lon2 - lon1
		
		let y = sin(dLon) * cos(lat2)
		let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
		let radiansBearing = atan2(y, x)
		
		return Utils.radiansToDegrees(radians: radiansBearing)
	}
}
