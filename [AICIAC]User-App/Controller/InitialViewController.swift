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
	let values7th = (98.44, 98.46)
	let values6th = (98.47, 98.49)
	let values5th = (98.50, 98.53)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		startGettingAirPressure()
	}
	
	func startGettingAirPressure() {
		altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) { (data, error) in
			if let data = data {
				let airPressure = data.pressure.doubleValue
//				if airPressure < self.values7th.1 {
					self.imageName = "bh_7th.png"
//				} else if airPressure > self.values6th.0 && airPressure < self.values6th.1 {
//					self.imageName = "bh_6th.png"
//				} else {
//					self.imageName = "bh_5h.png"
//				}
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
