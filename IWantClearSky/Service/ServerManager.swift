//
//  ServerManager.swift
//  IWantClearSky
//
//  Created by Anton Novoselov on 06.02.2021.
//

import Foundation
import CoreLocation
import SwiftyJSON

private enum LastSearchType {
    case byCoords
    case byCityName
}

class ServerManager {
    // MARK: - PROPERTIES
    private let baseUrl = "https://api.openweathermap.org/data/2.5"
    private let weatherUrlComponent = "/weather?"
    private let forecastUrlComponent = "/forecast/daily?"
    
    private let apiKey = "294c2bdc1cec983192f139eaf975b49a"
    private var lastSearchedWeatherLocation: CLLocation?
    private var lastSearchedCity: String?
    private var lastSearchType: LastSearchType = .byCoords
    
    public static let shared = ServerManager()
    private init() {}
    
    // MARK: - PUBLIC
    // MARK: - Current Weather methods
    public func getCurrentWeatherFor(location: CLLocation,
                                     needNotify: Bool = true,
                                     completion: @escaping (CurrentWeather) -> Void) {
        self.lastSearchedWeatherLocation = location
        self.lastSearchType = .byCoords
        var currentWeatherUrlString = "\(self.baseUrl)"
        currentWeatherUrlString += weatherUrlComponent
        currentWeatherUrlString += "lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(self.apiKey)&units=metric"
        
        let urlRequest = URLRequest(url: URL(string: currentWeatherUrlString)!)
        self.getCurrentWeartherWithURLRequest(urlRequest,
                                              needNotify: needNotify,
                                              completion: completion)
    }
    
    public func getCurrentWeatherFor(locationName: String,
                                     needNotify: Bool = true,
                                     completion: @escaping (CurrentWeather) -> Void) {
        self.lastSearchedCity = locationName
        self.lastSearchType = .byCityName
        
        var currentWeatherUrlString = "\(self.baseUrl)"
        currentWeatherUrlString += weatherUrlComponent
        currentWeatherUrlString += "q=\(locationName)&appid=\(self.apiKey)&units=metric"
        
        let urlRequest = URLRequest(url: URL(string: currentWeatherUrlString)!)
        self.getCurrentWeartherWithURLRequest(urlRequest,
                                              needNotify: needNotify,
                                              completion: completion)
    }
    
    // MARK: - Forecast Methods
    public func getForecastForLastSearched(completion: @escaping ([ForecastItem]) -> Void) {
        if self.lastSearchType == .byCoords, let location = self.lastSearchedWeatherLocation {
            self.getForecastFor(location: location, completion: completion)
        } else if let lastSearchedCity = self.lastSearchedCity {
            self.getForecastFor(city: lastSearchedCity, completion: completion)
        }
    }
    
    public func getForecastFor(location: CLLocation,
                               completion: @escaping ([ForecastItem]) -> Void) {
        var forecastUrlString = "\(self.baseUrl)"
        forecastUrlString += self.forecastUrlComponent
        forecastUrlString += "lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(self.apiKey)&units=metric"
        
        let urlRequest = URLRequest(url: URL(string: forecastUrlString)!)
        self.getForecastWithURLRequest(urlRequest, completion: completion)
    }
    
    public func getForecastFor(city: String,
                               completion: @escaping ([ForecastItem]) -> Void) {
        var forecastUrlString = "\(self.baseUrl)"
        forecastUrlString += self.forecastUrlComponent
        forecastUrlString += "q=\(city)&appid=\(self.apiKey)&units=metric"
        
        let urlRequest = URLRequest(url: URL(string: forecastUrlString)!)
        self.getForecastWithURLRequest(urlRequest, completion: completion)
    }
    
    public func fetchWeatherIconFor(iconId: String, completion: @escaping (Data) -> Void) {
        if let data = try? Data(contentsOf: self.getDocumentsDirectory().appendingPathComponent(iconId)) {
            completion(data)
            return
        }
        let urlString = "https://openweathermap.org/img/wn/\(iconId)@2x.png"
        let urlRequest = URLRequest(url: URL(string: urlString)!)
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let data = data else { return }
            try? data.write(to: self.getDocumentsDirectory().appendingPathComponent(iconId))
            completion(data)
            
        }.resume()
    }
    
    // MARK: - PRIVATE
    private func getCurrentWeartherWithURLRequest(_ urlRequest: URLRequest,
                                                  needNotify: Bool = true,
                                                  completion: @escaping (CurrentWeather) -> Void) {
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.parseCurrentWeatherJSONData(data,
                                             needNotify: needNotify,
                                             completion: completion)
        }.resume()
    }
    
    private func parseCurrentWeatherJSONData(_ data: Data?,
                                             needNotify: Bool = true,
                                             completion: @escaping (CurrentWeather) -> Void) {
        guard let data = data,
              let json = try? JSON(data: data) else { return }
        let responseCode = json["cod"].intValue
        if responseCode == 404 {
            print("city not found")
            return
        }
        
        let weatherDict = json["weather"].array?.first?.dictionary
        let date = json["dt"].double
        let sunrise = json["sys"]["sunrise"].double
        let sunset = json["sys"]["sunset"].double
        
        var isNight = false
        if let sunrise = sunrise,
           let sunset = sunset,
           let date = date {
            isNight = sunrise > date || date > sunset
        }
        
        let currentWeather = CurrentWeather(cityName: json["name"].string,
                                            currentTemp: json["main"]["temp"].double,
                                            description: weatherDict?["description"]?.string,
                                            iconId: weatherDict?["icon"]?.string,
                                            code: weatherDict?["id"]?.intValue,
                                            isNight: isNight)
        
        currentWeather.saveToCache()
        ForecastItem.invalidateForecastCache()
        if needNotify {
            NotificationCenter.default.post(name: NSNotification.Name(notificationCurrentWeatherDidLoad),
                                            object: nil)
        }
        completion(currentWeather)
    }
    
    private func getForecastWithURLRequest(_ urlRequest: URLRequest,
                                           completion: @escaping ([ForecastItem]) -> Void) {
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.parseForecastJSONData(data, completion: completion)
        }.resume()
    }
    
    private func parseForecastJSONData(_ data: Data?,
                                       completion: @escaping ([ForecastItem]) -> Void) {
        
        guard let data = data,
              let json = try? JSON(data: data),
              let jsonForecastItemsList = json["list"].array else { return }
        var forecastItems = [ForecastItem]()
        for jsonForecastItem in jsonForecastItemsList {
            let weatherDict = jsonForecastItem["weather"].array?.first?.dictionary
            let forecastItem = ForecastItem(weatherDescription: weatherDict?["description"]?.string,
                                            maxTemp: jsonForecastItem["temp"]["max"].double,
                                            minTemp: jsonForecastItem["temp"]["min"].double,
                                            date: Date(timeIntervalSince1970: jsonForecastItem["dt"].doubleValue),
                                            iconId: weatherDict?["icon"]?.string)
            
            forecastItems.append(forecastItem)
        }
        ForecastItem.saveForecastToCache(forecastItems: forecastItems)
        completion(forecastItems)
        
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
