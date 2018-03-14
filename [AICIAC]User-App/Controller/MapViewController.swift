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
	var path = [Location]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		showFloorPlan()
		self.navigationItem.title = imageName
		
		showCurrentLocation()
		setupNavBarButtons()
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showDestinationsSegue" {
			let destination = segue.destination as! DestinationsViewController
			destination.delegate = self
		}
	}
	
	func setupNavBarButtons() {
		let left = UIBarButtonItem(title: "Destinations", style: .plain, target: self, action: #selector(self.destinationsButtonPressed(sender:)))
		self.navigationItem.leftBarButtonItem = left
		
		let right = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(self.cameraButtonPressed(sender:)))
		self.navigationItem.rightBarButtonItem = right
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
				guard let x = data["x"] as? Double else { print("Failed to get x"); return }
				guard let y = data["y"] as? Double else { print("Faield to get y"); return }
				guard let standardHeight = data["standardHeight"] as? Double else { print("Failed to get standard height"); return }
				guard let standardWidth = data["standardWidth"] as? Double else { print("Failed standard width"); return }
				guard let lat = data["latitude"] as? Double else { print("Failed to get lat"); return }
				guard let long = data["longitude"] as? Double else { print("Failed to get long"); return }
				guard let roomID = data["roomID"] as? Int else { print("Failed to get room ID"); return }
				guard let id = data["id"] as? Int else { print("Failed to get id"); return }
				
				DispatchQueue.main.async {
					guard let interpolatedPoint = Utils.interpolatePointToCurrentSize(point: CGPoint(x: x, y: y), from: CGSize(width: standardWidth, height: standardHeight), in: self.mapImageView) else { return }
					let view = UIView(frame: CGRect(x: interpolatedPoint.x, y: interpolatedPoint.y, width: 10.0, height: 10.0))
					view.backgroundColor = UIColor.blue
					self.mapImageView.addSubview(view)
					self.currentLocation = Location.init(x: x, y: y, lat: lat, long: long, id: id, roomID: roomID, standardHeight: standardHeight, standardWidth: standardWidth)
					self.currentLocation.view = view
				}
			}
		}
	}
	
	func showRouteToDestination(destination: Room) {
		NavigationHelper.shared.getConnectingLocation(in: destination) { (success, location) in
			if success == true {
				NavigationHelper.shared.getRoute(from: self.currentLocation, to: location!, completion: { (success, path) in
					if success == true {
						let group = DispatchGroup()
						for element in path! {
							group.enter()
							NavigationHelper.shared.getLocation(with: element, completion: { (response, location) in
								if response == true {
									DispatchQueue.main.async {
										guard let interpolatedPoint = Utils.interpolatePointToCurrentSize(point: CGPoint(x: location!.x, y: location!.y), from: CGSize(width: location!.standardWidth, height: location!.standardHeight), in: self.mapImageView) else { return }
										let view = UIView(frame: CGRect(x: interpolatedPoint.x, y: interpolatedPoint.y, width: 10.0, height: 10.0))
										view.backgroundColor = UIColor.red
										self.mapImageView.addSubview(view)
										self.path.append(location!)
									}
								}
								group.leave()
							})
						}
						
						group.notify(queue: DispatchQueue.main, execute: {
							DispatchQueue.main.async {
								self.drawPath()
							}
						})
					}
				})
			}
		}
	}
	
	func drawPath() {
		var first = path[0]
		print(first)
		for index in 1..<path.count {
			print(path[index])
			if let point1 = Utils.interpolatePointToCurrentSize(point: CGPoint(x: first.x, y: first.y), from: CGSize(width: first.standardWidth, height: first.standardHeight), in: self.mapImageView), let point2 = Utils.interpolatePointToCurrentSize(point: CGPoint(x: path[index].x, y: path[index].y), from: CGSize(width: path[index].standardWidth, height: path[index].standardHeight), in: self.mapImageView) {
				addLine(fromPoint: point1, toPoint: point2, in: self.mapImageView)
			}
			first = path[index]
		}
	}
	
	func generateDirections() -> [String] {
		var instructions = [String]()
		var prev = path[0]
		for index in 1..<path.count {
			let current = path[index]
			
			if current.roomID != prev.roomID {
				instructions.append("Exit the room.")
			}
			
			prev = current
		}
		return instructions
	}
	
	func addLine(fromPoint start: CGPoint, toPoint end: CGPoint, in view: UIView) {
		let line = CAShapeLayer()
		let linePath = UIBezierPath()
		linePath.move(to: start)
		linePath.addLine(to: end)
		line.path = linePath.cgPath
		line.strokeColor = UIColor.red.cgColor
		line.lineWidth = 1
		line.lineJoin = kCALineJoinRound
		view.layer.addSublayer(line)
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
	
	// MARK: - User interaction

	@objc func destinationsButtonPressed(sender: UIBarButtonItem) {
		performSegue(withIdentifier: "showDestinationsSegue", sender: self)
	}
	
	@objc func cameraButtonPressed(sender: UIBarButtonItem) {
		performSegue(withIdentifier: "showARSegue", sender: self)
	}
}

extension MapViewController: DestinationSelectedDelegate {
	func userSelectedDestination(destination: Room) {
		showRouteToDestination(destination: destination)
	}
}
