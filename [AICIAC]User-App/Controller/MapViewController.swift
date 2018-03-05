//
//  MapViewController.swift
//  [AICIAC]User-App
//
//  Created by Alexandru Clapa on 01/03/2018.
//  Copyright © 2018 Alexandru Clapa. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
	@IBOutlet weak var mapImageView: UIImageView!
	
	var currentLocation = Location()
	var imageName = ""
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		showFloorPlan()
		self.navigationItem.title = imageName
		
		showCurrentLocation()
    }
	
	func showFloorPlan() {
		if let image = UIImage(named: imageName) {
			mapImageView.image = image
		}
	}
	
	func showCurrentLocation() {
		NavigationHelper.shared.getCurrentPosition { (success, data) in
			if success == true {
				guard let data = data else { return }
				guard let x = data["x"] as? Double else { return }
				guard let y = data["y"] as? Double else { return }
				guard let standardHeight = data["standardHeight"] as? Double else { return }
				guard let standardWidth = data["standardWidth"] as? Double else { return }
				guard let lat = data["latitude"] as? Double else { return }
				guard let long = data["longigtude"] as? Double else { return }
				guard let roomID = data["roomID"] as? Int else { return }
				guard let id = data["id"] as? Int else { return }
				
				DispatchQueue.main.async {
					guard let interpolatedPoint = Utils.interpolatePointToCurrentSize(point: CGPoint(x: x, y: y), from: CGSize(width: standardWidth, height: standardHeight), in: self.view) else { return }
					let view = UIView(frame: CGRect(x: interpolatedPoint.x, y: interpolatedPoint.y, width: 10.0, height: 10.0))
					view.backgroundColor = UIColor.red
					self.view.addSubview(view)
					self.currentLocation = Location.init(x: x, y: y, lat: lat, long: long, id: id, roomID: roomID, standardHeight: standardHeight, standardWidth: standardWidth)
				}
			}
		}
	}
	
	func drawPositionCircleView(in rect: CGRect) -> UIView {
		let circle = UIView(frame: rect)
		
		circle.center = self.view.center
		circle.layer.cornerRadius = 50
		circle.backgroundColor = UIColor.black
		circle.clipsToBounds = true
		
		
		let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.dark)
		let blurView = UIVisualEffectView(effect: darkBlur)
		
		blurView.frame = circle.bounds
		
		circle.addSubview(blurView)
		
		return circle
	}

}
