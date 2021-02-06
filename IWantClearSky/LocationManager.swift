//
//  GeoLocationManager.swift
//  IWantClearSky
//
//  Created by Anton Novoselov on 06.02.2021.
//

import Foundation
import CoreLocation

protocol GeoLocationManagerDelegate: AnyObject {
    func didUpdateLocation(location: CLLocation)
}

class GeoLocationManager {
    public static let shared = GeoLocationManager()
    private init() {}
    
    let locationManager = CLLocationManager()
    
    var latitude: Double!
    var longitude: Double!
    
    weak var delegate: GeoLocationManagerDelegate?
    
    public func getLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            if let location = locationManager.location {
                self.delegate?.didUpdateLocation(location: location)
                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
            self.getLocation()
        }
    }
}
