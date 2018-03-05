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
}
