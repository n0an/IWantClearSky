//
//  LocationManager.swift
//  IWantClearSky
//
//  Created by Anton Novoselov on 08.02.2021.
//

import Foundation
import CoreLocation

// MARK: - LocationManagerDelegate
public protocol LocationManagerDelegate: AnyObject {
    func didUpdateLocation(location: CLLocation)
    func didGetErrorLocationServicesForbidden()
    func didFailWithError(error: Error)
}

class LocationManager: NSObject {
    // MARK: - PROPERTIES
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    public weak var delegate: LocationManagerDelegate?
    
    // MARK: - INIT
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - PUBLIC
    func getLastLocation() -> CLLocation? {
        return self.lastLocation
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied:
            locationManager.stopUpdatingLocation()
            self.delegate?.didGetErrorLocationServicesForbidden()
        case .notDetermined:
            locationManager.stopUpdatingLocation()
        case .restricted:
            locationManager.stopUpdatingLocation()
        @unknown default: assertionFailure("Location manager status is unknown!")
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else { return }
        self.lastLocation = last
        self.delegate?.didUpdateLocation(location: last)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.delegate?.didFailWithError(error: error)
    }
}
