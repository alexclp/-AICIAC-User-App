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

	var imageName = ""
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		showFloorPlan()
		self.navigationItem.title = imageName
		
//		NavigationHelper.shared.getCurrentPosition()
    }
	
	func showFloorPlan() {
		if let image = UIImage(named: imageName) {
			mapImageView.image = image
		}
	}

}
