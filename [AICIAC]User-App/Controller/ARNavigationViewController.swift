
//  AugmentedRealityViewController.swift
//  [AICIAC]User-App
//
//  Created by Alexandru Clapa on 14/03/2018.
//  Copyright © 2018 Alexandru Clapa. All rights reserved.
//

import UIKit
import ARKit
import CoreLocation

class ARNavigationViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

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
		
		locationManager = CLLocationManager()
		locationManager.delegate = self
		
		if let location = currentPosition {
			sceneLocationView.locationManager.currentLocation = CLLocation(latitude: CLLocationDegrees.init(location.lat), longitude: CLLocationDegrees.init(location.long))
			sceneLocationView.locationManager.locationManager?.stopUpdatingLocation()
		}
		
		if destination != nil {
			let configuration = ARWorldTrackingConfiguration()
			configuration.planeDetection = .horizontal
			sceneView.session.run(configuration)
			
			sceneView.delegate = self
			sceneView.showsStatistics = true
			//		sceneView.scene = SCNScene()
			sceneView.autoenablesDefaultLighting = true
			
			calculateBearing()
			showNavigationArrow()
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		sceneView.session.pause()
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
	
	func calculateBearing() {
		if angle == -1 {
			angle = Utils.shared.getBearingBetweenTwoPoints(point1: currentPosition!, point2: destination!)
			compassNode?.rotation = SCNVector4(0, 0.5, -4, (angle / 180) * Double.pi)
		}
	}
}

extension ARNavigationViewController: CLLocationManagerDelegate {
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
