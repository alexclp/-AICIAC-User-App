//
//  LocationManager.swift
//  ARKit+CoreLocation
//
//  Created by Andrew Hart on 02/07/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: class {
    func locationManagerDidUpdateLocation(_ locationManager: LocationManager, location: CLLocation)
    func locationManagerDidUpdateHeading(_ locationManager: LocationManager, heading: CLLocationDirection, accuracy: CLLocationDirection)
}

///Handles retrieving the location and heading from CoreLocation
///Does not contain anything related to ARKit or advanced location
class LocationManager: NSObject {
    weak var delegate: LocationManagerDelegate?
    
	var locationManager: IndoorLocationManager?
	var headingManager: CLLocationManager?
    
    var currentLocation: CLLocation?
    
    var heading: CLLocationDirection?
    var headingAccuracy: CLLocationDegrees?
    
    override init() {
        super.init()
        
        self.locationManager = IndoorLocationManager()
        self.locationManager!.delegate = self
		self.locationManager?.startUpdatingLocation()
		
		self.headingManager = CLLocationManager()
		
		self.headingManager = CLLocationManager()
		self.headingManager!.desiredAccuracy = kCLLocationAccuracyBestForNavigation
		self.headingManager!.distanceFilter = kCLDistanceFilterNone
		self.headingManager!.headingFilter = kCLHeadingFilterNone
		self.headingManager!.pausesLocationUpdatesAutomatically = false
		self.headingManager!.delegate = self
		self.headingManager!.startUpdatingHeading()
		self.headingManager!.startUpdatingLocation()
		
		self.headingManager!.requestWhenInUseAuthorization()
    }
    
    func requestAuthorization() {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse {
            return
        }
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.restricted {
            return
        }
        
        self.headingManager?.requestWhenInUseAuthorization()
	}
}

extension LocationManager: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		if newHeading.headingAccuracy >= 0 {
			self.heading = newHeading.trueHeading
		} else {
			self.heading = newHeading.magneticHeading
		}
		
		self.headingAccuracy = newHeading.headingAccuracy
		
		self.delegate?.locationManagerDidUpdateHeading(self, heading: self.heading!, accuracy: newHeading.headingAccuracy)
	}
	
	func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
		return true
	}
}

extension LocationManager: IndoorLocationManagerDelegate {
	func locationManager(_ manager: IndoorLocationManager, didUpdateLocation location: Location) {
		DispatchQueue.main.async {
			let coreLocationInstance = CLLocation.init(latitude: CLLocationDegrees.init(location.lat), longitude: CLLocationDegrees(location.long))
			self.delegate?.locationManagerDidUpdateLocation(self, location: coreLocationInstance)
			self.currentLocation = coreLocationInstance
		}
	}
}
