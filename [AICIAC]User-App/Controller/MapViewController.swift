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
	@IBOutlet weak var distanceLabel: UILabel!
	@IBOutlet weak var etaLabel: UILabel!
	
	let averageWalkSpeed = 1.4
	
	var currentLocation: Location? = nil
	var destinationLocation: Location? = nil
	var imageName = ""
	var path = [Location]()
	let locationManager = IndoorLocationManager()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		showFloorPlan()
		self.navigationItem.title = imageName
		
		if let location = currentLocation {
			placeLocation(location: location, in: mapImageView)
		}
		
		locationManager.delegate = self
		setupNavBarButtons()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		locationManager.startUpdatingLocation()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillAppear(animated)
		locationManager.stopUpdatingLocation()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showDestinationsSegue" {
			let destination = segue.destination as! DestinationsViewController
			destination.delegate = self
			destination.floorNumber = currentLocation!.floorNumber
		} else if segue.identifier == "showARNavigationSegue" {
			let destination = segue.destination as! ARNavigationViewController
			if let current = currentLocation {
				destination.currentPosition = current
			}
			
			if let dest = destinationLocation {
				destination.destination = dest
			}
		} else if segue.identifier == "showARInformationSegue" {
			let destination = segue.destination as! ARLocationInformationViewController
			if let current = currentLocation {
				destination.currentPosition = current
			}
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
	
	func placeLocation(location: Location, in view: UIView) {
		guard let interpolatedPoint = Utils.interpolatePointToCurrentSize(point: CGPoint(x: location.x, y: location.y), from: CGSize(width: location.standardWidth, height: location.standardHeight), in: view) else { return }
		let locationView = UIView(frame: CGRect(x: interpolatedPoint.x, y: interpolatedPoint.y, width: 8.0, height: 8.0))
		locationView.backgroundColor = UIColor.blue
		view.addSubview(locationView)
		self.currentLocation = location
		self.currentLocation?.view = locationView
	}
	
	func showRouteToDestination(destination: Room) {
		NavigationHelper.shared.getConnectingLocation(in: destination) { (success, location) in
			if success == true {
				self.destinationLocation = location
				NavigationHelper.shared.getRoute(from: self.currentLocation!, to: location!, completion: { (success, navigationData) in
					if success == true {
						guard let navigationData = navigationData else { return }
						
						if let distance = navigationData["distance"] as? Double {
							let eta = distance / self.averageWalkSpeed
							DispatchQueue.main.async {
//								self.etaLabel.text = "ETA: \(Int(eta)) seconds"
//								self.distanceLabel.text = "\(Int(distance))m"
								self.etaLabel.text = "\(Int(distance))meters, \(Int(eta))seconds"
							}
						}
						
						if let path = navigationData["path"] as? [Int] {
							let group = DispatchGroup()
							for element in path {
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
									self.path.sort(by: { (a, b) -> Bool in
										a.id < b.id
									})
									self.drawPath()
								}
							})
						}
					}
				})
			}
		}
	}
	
	func drawPath() {
		var first = path[0]
		print(first.id)
		for index in 1..<path.count {
			print(path[index].id)
			if let point1 = Utils.interpolatePointToCurrentSize(point: CGPoint(x: first.x, y: first.y), from: CGSize(width: first.standardWidth, height: first.standardHeight), in: self.mapImageView), let point2 = Utils.interpolatePointToCurrentSize(point: CGPoint(x: path[index].x, y: path[index].y), from: CGSize(width: path[index].standardWidth, height: path[index].standardHeight), in: self.mapImageView) {
				addLine(fromPoint: point1, toPoint: point2, in: self.mapImageView)
			}
			first = path[index]
		}
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
	
	// MARK: - User interaction

	@objc func destinationsButtonPressed(sender: UIBarButtonItem) {
		performSegue(withIdentifier: "showDestinationsSegue", sender: self)
	}
	
	@objc func cameraButtonPressed(sender: UIBarButtonItem) {
		// performSegue(withIdentifier: "showARSegue", sender: self)
		let alert = UIAlertController(title: "Please select an option:", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
		let navigationButton = UIAlertAction(title: "Show navigation guidance", style: .default) { (alert) -> Void in
			self.performSegue(withIdentifier: "showARNavigationSegue", sender: self)
		}
		
		let informationButton = UIAlertAction(title: "Show information from around my location", style: .default) { (alert) -> Void in
			self.performSegue(withIdentifier: "showARInformationSegue", sender: self)
		}
		
		let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (alert) -> Void in
			self.dismiss(animated: true, completion: nil)
		}
		
		alert.addAction(navigationButton)
		alert.addAction(informationButton)
		alert.addAction(cancelButton)
		self.present(alert, animated: true, completion: nil)
	}
}

extension MapViewController: DestinationSelectedDelegate {
	func userSelectedDestination(destination: Room) {
		showRouteToDestination(destination: destination)
	}
}

extension MapViewController: IndoorLocationManagerDelegate {
	func locationManager(_ manager: IndoorLocationManager, didUpdateLocation location: Location) {
		DispatchQueue.main.async {
			// First remove the previous one, if there is one
			if let location = self.currentLocation {
				location.view?.removeFromSuperview()
			}
			
			// Then show the new one
			self.placeLocation(location: location, in: self.mapImageView)
		}
	}
}
