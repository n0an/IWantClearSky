//
//  MainViewController.swift
//  IWantClearSky
//
//  Created by Anton Novoselov on 05.02.2021.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController, Alertable {
    // MARK: - OUTLETS
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var currentWeatherImageView: UIImageView!
    @IBOutlet weak var locationsButton: UIButton!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    // MARK: - PROPERTIES
    private var bgImageView: UIImageView!
    private var forcedStatusBarStyle: UIStatusBarStyle = .default
    var locationManager: LocationManager!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return forcedStatusBarStyle
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.getCurrentWeatherFromCache()
        self.setupLocationManager()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.setupLayout()
    }
    
    // MARK: - PUBLIC
    public func presentSearchAndGetCurrentWeather() {
        self.presentSearchCityAlertController(withTitle: "Enter city", message: nil, style: .alert) { city in
            self.getCurrentWeatherFor(city: city)
            var citiesArray = LocationsViewController.loadCitiesFromCache()
            if citiesArray.contains(city) == false {
                citiesArray.append(city)
                LocationsViewController.saveCitiesToCache(cities: citiesArray)
            }
        }
    }
    
    // MARK: - PRIVATE
    private func setupUI() {
        self.bgImageView = UIImageView()
        self.view.insertSubview(self.bgImageView, at: 0)
    }
    
    private func setupLocationManager() {
        self.locationManager = LocationManager()
        self.locationManager.delegate = self
    }
    
    private func setupLayout() {
        self.bgImageView.translatesAutoresizingMaskIntoConstraints = false
        [self.bgImageView.topAnchor.constraint(equalTo: self.view.topAnchor),
         self.bgImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
         self.bgImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
         self.bgImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)].forEach {$0.isActive = true}
    }
    
    private func getCurrentWeatherFromCache() {
        if let cachedCurrentWeather = CurrentWeather.loadFromCache() {
            self.updateUIWithCurrentWeather(cachedCurrentWeather)
        }
    }
    
    private func getCurrentWeatherFor(location: CLLocation) {
        ServerManager.shared.getCurrentWeatherFor(location: location) { [weak self] currentWeather in
            DispatchQueue.main.async {
                self?.updateUIWithCurrentWeather(currentWeather)
            }
        }
    }
    
    private func getCurrentWeatherFor(city: String) {
        ServerManager.shared.getCurrentWeatherFor(locationName: city) { [weak self] currentWeather in
            DispatchQueue.main.async {
                self?.updateUIWithCurrentWeather(currentWeather)
            }
        }
    }
    
    private func updateUIWithCurrentWeather(_ currentWeather: CurrentWeather) {
        self.locationLabel.text = currentWeather.cityName ?? "--"
        if let currentTemp = currentWeather.currentTemp {
            self.temperatureLabel.text = currentWeather.getTemperatureStr(temp: currentTemp)
            var hint = ""
            if currentTemp < 0 {
                hint = "It's frosty outside. Wear more clothes"
            } else if 0...15 ~= currentTemp  {
                hint = "It's quite cold"
            } else {
                hint = "Pretty warm outside"
            }
            self.hintLabel.text = hint
        }
        
        self.weatherDescriptionLabel.text = currentWeather.description?.capitalized
        let tintColor = currentWeather.isNight ? UIColor.white : .black
        
        self.forcedStatusBarStyle = currentWeather.isNight ? .lightContent : .darkContent
        self.setNeedsStatusBarAppearanceUpdate()
        
        [self.locationLabel,
         self.temperatureLabel,
         self.weatherDescriptionLabel,
         self.hintLabel].forEach {$0?.textColor = tintColor}
        
        [self.locationsButton,
         self.currentLocationButton].forEach {$0?.tintColor = tintColor}
        
        if let weatherCode = currentWeather.code {
            var conditionStr = "clear"
            switch weatherCode {
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
    }
    
    // MARK: - ACTIONS
    @IBAction func actionLocationsButtonTapped(_ sender: Any) {
        let listVc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "LocationsViewController") as! LocationsViewController
        listVc.delegate = self
        let navVc = UINavigationController(rootViewController: listVc)
        navVc.modalPresentationStyle = .fullScreen
        self.present(navVc, animated: true, completion: nil)
    }
    
    @IBAction func actionCurrentLocationTapped(_ sender: Any) {
        self.locationManager.requestLocationUpdate()
    }
}

// MARK: - LocationManagerDelegate
extension MainViewController: LocationManagerDelegate {
    func didGetErrorLocationServicesForbidden() {
        self.presentAlert(title: LocationServicesErrorTitle,
                          message: LocationServicesErrorMessage,
                          actionTitle: "OK")
    }
    
    func didUpdateLocation(location: CLLocation) {
        self.getCurrentWeatherFor(location: location)
    }
}

// MARK: - LocationsViewControllerDelegate
extension MainViewController: LocationsViewControllerDelegate {
    func didSelect(city: String) {
        self.getCurrentWeatherFor(city: city)
    }
}
