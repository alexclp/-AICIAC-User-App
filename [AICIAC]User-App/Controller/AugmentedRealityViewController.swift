
//  AugmentedRealityViewController.swift
//  [AICIAC]User-App
//
//  Created by Alexandru Clapa on 14/03/2018.
//  Copyright © 2018 Alexandru Clapa. All rights reserved.
//

import UIKit
import ARKit
import CoreLocation

class AugmentedRealityViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

	// MARK: - IBOutlets
	
	@IBOutlet weak var sessionInfoView: UIView!
	@IBOutlet weak var sessionInfoLabel: UILabel!
	@IBOutlet weak var sceneView: ARSCNView!
	
	var sceneLocationView = SceneLocationView()
	
	var destination: Location? = nil
	var currentPosition: Location? = nil
	
	var compassNode: SCNNode? = nil
	var locationManager: CLLocationManager!
	var angle: Double = -1
	
	let configuration = ARWorldTrackingConfiguration()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Set the view's delegate
//		sceneLocationView.delegate = self
//		sceneLocationView.showsStatistics = true
//		sceneLocationView.scene = SCNScene()
//		sceneLocationView.autoenablesDefaultLighting = true
		
		locationManager = CLLocationManager()
		locationManager.delegate = self
	
		let pinCoordinate = CLLocationCoordinate2D(latitude: 51.512299055661046, longitude: -0.11711540728893481)
		let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: 15)
		let pinImage = UIImage(named: "timetable.png")!
		let pinLocationNode = LocationAnnotationNode(location: pinLocation, image: pinImage)
//		pinLocationNode.scaleRelativeToDistance = true
		sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
		view.addSubview(sceneLocationView)
//		destination = Location()
//		currentPosition = Location()
		
//		destination?.lat = 51.510790
//		destination?.long = -0.116974
		
//		currentPosition?.lat = 51.512549
//		currentPosition?.long = -0.117021
		
//		if currentPosition != nil && destination != nil {
//			calculateBearing()
//		}
		
//		calculateBearing()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		sceneLocationView.frame = view.bounds
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
//		configuration.worldAlignment = .gravityAndHeading
//		sceneLocationView.session.run(configuration)
		sceneLocationView.run()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		sceneLocationView.session.pause()
		angle = -1
	}
	
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
		if currentPosition != nil && destination != nil {
			guard let camera = sceneView.pointOfView else { return }
			let position = SCNVector3(x: 0, y: 0.5, z: -4)
			compassNode?.position = camera.convertPosition(position, to: nil)
		}
	}
	
	func showNavigationArrow() {
		if let compassScene = SCNScene(named: "art.scnassets/arrow.scn") {
			if let node = compassScene.rootNode.childNode(withName: "arrow", recursively: true) {
				compassNode = node
				sceneView.scene.rootNode.addChildNode(node)
			}
		}
	}
	
	func createTimetables() {
		
	}
	
	func calculateBearing() {
		if angle == -1 {
			angle = Utils.shared.getBearingBetweenTwoPoints1(point1: currentPosition!, point2: destination!)
			compassNode?.rotation = SCNVector4(0, 0.5, -4, (angle / 180) * Double.pi)
		}
	}
	
	// MARK: - Data fetching
	
	func getCloseLocations(completion: @escaping ([String: Location]?) -> Void) {
		guard let currentLocation = currentPosition else { return }
		ARDataHelper.shared.closestLocations(currentLocation: currentLocation) { (response, json) in
			if response == true {
				guard let json = json else { return }
				var toReturn = [String: Location]()
				for (key, object) in json {
					if let object = object as? [String: Any] {
						let location = Location.init()
						location.id = object["id"] as! Int
						location.lat = object["latitude"] as! Double
						location.long = object["longitude"] as! Double
						location.x = object["x"] as! Double
						location.y = object["y"] as! Double
						location.standardWidth = object["standardWidth"] as! Double
						location.standardHeight = object["standardHeight"] as! Double
						location.roomID = object["roomID"] as! Int
						toReturn[key] = location
					}
				}
				completion(toReturn)
			}
		}
	}
}

extension AugmentedRealityViewController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		switch status {
		case .notDetermined:
			locationManager.requestWhenInUseAuthorization()
			break
		case .denied:
			break
		case .restricted:
			break
		case .authorizedAlways:
			break
		case .authorizedWhenInUse:
			locationManager.headingFilter = kCLHeadingFilterNone
			locationManager.headingOrientation = .portrait
			locationManager.startUpdatingHeading()
			break
		}
	}
}
