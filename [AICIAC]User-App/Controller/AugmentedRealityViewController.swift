//
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
	
	var destination = Location()
	var currentPosition = Location()
	var compassNode: SCNNode? = nil
	var locationManager: CLLocationManager!
	var angle: Double = -1
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Set the view's delegate
		sceneView.delegate = self
		sceneView.showsStatistics = true
		sceneView.scene = SCNScene()
		sceneView.autoenablesDefaultLighting = true
		
		if let compassScene = SCNScene(named: "art.scnassets/arrow.scn") {
			if let node = compassScene.rootNode.childNode(withName: "arrow", recursively: true) {
				compassNode = node
				sceneView.scene.rootNode.addChildNode(node)
			}
		}
		locationManager = CLLocationManager()
		locationManager.delegate = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		let configuration = ARWorldTrackingConfiguration()
		sceneView.session.run(configuration)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		sceneView.session.pause()
		angle = -1
	}
	
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
		guard let camera = sceneView.pointOfView else { return }
		let position = SCNVector3(x: 0, y: 0.5, z: -4)
		compassNode?.position = camera.convertPosition(position, to: nil)
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
	
	func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		if angle == -1 {
			angle = newHeading.magneticHeading
			compassNode?.rotation = SCNVector4(0, 0.5, -4, (angle / 180) * Double.pi)
		}
	}
}
