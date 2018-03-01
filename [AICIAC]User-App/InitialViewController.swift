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

	let altimeter = CMAltimeter()
	var imageName = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		startGettingAirPressure()
	}
	
	func startGettingAirPressure() {
		altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) { (data, error) in
			if let data = data {
//				let airPressure = data.pressure.doubleValue
				self.imageName = "bh_7th.png"
				self.performSegue(withIdentifier: "showMapSegue", sender: self)
				self.stopGettingAirPressure()
			} else {
				if let error = error {
					print(error)
				}
			}
		}
	}
	
	func stopGettingAirPressure() {
		altimeter.stopRelativeAltitudeUpdates()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showMapSegue" {
			let destination = segue.destination as! UINavigationController
			let mapVC = destination.viewControllers[0] as! MapViewController
			mapVC.imageName = imageName
		}
	}

}
