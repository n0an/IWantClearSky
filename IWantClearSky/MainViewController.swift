//
//  MainViewController.swift
//  IWantClearSky
//
//  Created by Anton Novoselov on 05.02.2021.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var currentWeatherImageView: UIImageView!
    
    // MARK: - PROPERTIES
    var currentLocation: CLLocation!
    var bgImageView: UIImageView!
    
    var forcedStatusBarStyle: UIStatusBarStyle = .default
    
    lazy var locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyKilometer
        lm.requestWhenInUseAuthorization()
        return lm
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return forcedStatusBarStyle
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        GeoLocationManager.shared.delegate = self
        
        self.bgImageView = UIImageView()
        self.view.insertSubview(self.bgImageView, at: 0)
        
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        GeoLocationManager.shared.getLocation()
        
        self.bgImageView.translatesAutoresizingMaskIntoConstraints = false
        [self.bgImageView.topAnchor.constraint(equalTo: self.view.topAnchor),
         self.bgImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
         self.bgImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
         self.bgImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)].forEach {$0.isActive = true}
    }
    
}


extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
//        let latitude = location.coordinate.latitude
//        let longitude = location.coordinate.longitude
//
        self.currentLocation = location
//        55,755786
//        37,617633
        ServerManager.shared.getCurrentWeatherFor(location: location) { currentWeather in
            
            self.locationLabel.text = currentWeather.cityName ?? "--"
            self.temperatureLabel.text = currentWeather.prepareTemperatureStr(temp: currentWeather.currentTemp)
            self.weatherDescriptionLabel.text = currentWeather.description?.capitalized
            
            let labelsColor = currentWeather.isNight ? UIColor.white : .black
            
            self.forcedStatusBarStyle = currentWeather.isNight ? .lightContent : .darkContent
            self.setNeedsStatusBarAppearanceUpdate()

            [self.locationLabel,
             self.temperatureLabel,
             self.weatherDescriptionLabel,
             self.hintLabel].forEach {$0?.textColor = labelsColor}
            
            var hint = ""
            if currentWeather.currentTemp < 0 {
                hint = "It's frosty outside. Wear more clothes"
            } else if 0...15 ~= currentWeather.currentTemp  {
                hint = "It's quite cold"
            } else {
                hint = "Pretty warm outside"
            }
            self.hintLabel.text = hint
            
            var conditionStr = "clear"
            
            switch currentWeather.code {
            case 800:
                conditionStr = "clear"
            case 500...531:
                conditionStr = "rain"
            case 600...632:
                conditionStr = "snow"
            case 801...804:
                conditionStr = "partly_cloudy"
            default:
                break
            }
            
            let dayOrNightStr = currentWeather.isNight ? "night" : "day"
            
            let bgImageName = "bg_\(conditionStr)_\(dayOrNightStr)"
            
            self.bgImageView.image = UIImage(named: bgImageName)
            
            let iconImageName = "weather_condition_\(conditionStr)_\(dayOrNightStr)"
            
            self.currentWeatherImageView.image = UIImage(named: iconImageName)
            
        }
        
//        networkWeatherManager.fetchCurrentWeather(forRequestType: .coordinate(latitude: latitude, longitude: longitude))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}


// MARK: - GeoLocationManagerDelegate
extension MainViewController: GeoLocationManagerDelegate {
    func didUpdateLocation(location: CLLocation) {
        self.currentLocation = location
//        55,755786
//        37,617633
        ServerManager.shared.getCurrentWeatherFor(location: location) { currentWeather in
            
            self.locationLabel.text = currentWeather.cityName ?? "--"
            self.temperatureLabel.text = currentWeather.prepareTemperatureStr(temp: currentWeather.currentTemp)
            self.weatherDescriptionLabel.text = currentWeather.description?.capitalized
            
            var hint = ""
            if currentWeather.currentTemp < 0 {
                hint = "It's frosty outside. Wear more clothes"
            } else if 0...15 ~= currentWeather.currentTemp  {
                hint = "It's quite cold"
            } else {
                hint = "Pretty warm outside"
            }
            self.hintLabel.text = hint
            
            if let iconId = currentWeather.iconId {
                ServerManager.shared.fetchWeatherIconFor(iconId: iconId) { data in
                    self.currentWeatherImageView.image = UIImage(data: data)
                }
            }
        }
    }
}
