//
//  LocationInformationViewController.swift
//  [AICIAC]User-App
//
//  Created by Alexandru Clapa on 12/04/2018.
//  Copyright © 2018 Alexandru Clapa. All rights reserved.
//

import UIKit
import ARKit
import CoreLocation

class ARLocationInformationViewController: UIViewController, CLLocationManagerDelegate {
	var sceneLocationView = SceneLocationView()
	var currentPosition: Location? = nil
	let configuration = ARWorldTrackingConfiguration()
	var locationManager: CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		locationManager = CLLocationManager()
		locationManager.delegate = self
		
		if let location = currentPosition {
			sceneLocationView.locationManager.currentLocation = CLLocation(latitude: CLLocationDegrees.init(location.lat), longitude: CLLocationDegrees.init(location.long))
			sceneLocationView.locationManager.locationManager?.stopUpdatingLocation()
		}
		
		sceneLocationView.session.run(configuration)
		sceneLocationView.run()
		self.view.addSubview(sceneLocationView)
		placeTimetables()
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		sceneLocationView.frame = view.bounds
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		sceneLocationView.session.pause()
	}

	func placeTimetables() {
		guard let currentLocation = currentPosition else { return }
		ARDataHelper.shared.closestLocations(currentLocation: currentLocation) { (response, data) in
			if response == true {
				guard let locationsInRooms = data else { return }
				for (roomName, location) in locationsInRooms {
					if roomName == "South Wing Corridor" {
						continue
					}
					
					ARDataHelper.shared.getTimetableImageFor(roomName: roomName, completion: { (response, image) in
						if response == true {
							guard let image = image else { return }
							let pinCoordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.long)
							let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: 5)
							let pinImage = image
							let pinLocationNode = LocationAnnotationNode(location: pinLocation, image: pinImage)
							pinLocationNode.scaleRelativeToDistance = true
							self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
						}
					})
				}
			}
		}
	}
	
	func placeAvailableComputers() {
		guard let currentLocation = currentPosition else { return }
		ARDataHelper.shared.closestLocations(currentLocation: currentLocation) { (response, data) in
			if response == true {
				guard let locationsInRooms = data else { return }
				for (roomName, location) in locationsInRooms {
					if roomName == "South Wing Corridor" {
						continue
					}
					
					ARDataHelper.shared.getComputersAvailability(roomName: roomName, completion: { (response, image) in
						if response == true {
							guard let image = image else { return }
							let pinCoordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.long)
							let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: 0)
							let pinImage = image
							let pinLocationNode = LocationAnnotationNode(location: pinLocation, image: pinImage)
							pinLocationNode.scaleRelativeToDistance = true
							self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
						}
					})
				}
 			}
		}
	}
}
