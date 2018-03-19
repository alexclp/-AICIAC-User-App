//
//  ViewController.swift
//  [AICIAC]User-App
//
//  Created by Alexandru Clapa on 07/02/2018.
//  Copyright © 2018 Alexandru Clapa. All rights reserved.
//

import UIKit
import CoreMotion

class InitialViewController: UIViewController {
	@IBOutlet weak var imageView: UIImageView!

	var imageName = ""
	let locationManager = IndoorLocationManager()
	var currentLocation: Location? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		SwiftSpinner.useContainerView(self.view)
		SwiftSpinner.show("Calculating current location...")
		locationManager.delegate = self
		locationManager.startUpdatingLocation()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showMapSegue" {
			let destination = segue.destination as! UINavigationController
			let mapVC = destination.viewControllers[0] as! MapViewController
			mapVC.imageName = imageName
			mapVC.currentLocation = currentLocation
		}
	}
}

extension InitialViewController: IndoorLocationManagerDelegate {
	func locationManager(_ manager: IndoorLocationManager, didUpdateLocation location: Location) {
		DispatchQueue.main.async {
			SwiftSpinner.hide()
			self.locationManager.stopUpdatingLocation()
			self.imageName = "bh_\(location.floorNumber)th.png"
			self.currentLocation = location
			self.performSegue(withIdentifier: "showMapSegue", sender: self)
		}
	}
}
