//
//  ServerManager.swift
//  IWantClearSky
//
//  Created by Anton Novoselov on 06.02.2021.
//

import Foundation
import CoreLocation
import SwiftyJSON

class ServerManager {
    let baseUrl = "https://api.openweathermap.org/data/2.5"
    let weatherUrlComponent = "weather?"
    let forecastUrlComponent = "forecast/daily?"
    let apiKey = "294c2bdc1cec983192f139eaf975b49a"
    
    var lastWeatherLocation: CLLocation?
    
    public static let shared = ServerManager()
    private init() {}
    
    public func getCurrentWeatherFor(location: CLLocation,
                                     completion: @escaping (CurrentWeather) -> Void) {
        self.lastWeatherLocation = location
        let currentWeatherUrl = "\(self.baseUrl)/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(self.apiKey)&units=metric"
        let urlRequest = URLRequest(url: URL(string: currentWeatherUrl)!)
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                guard let data = data,
                      let json = try? JSON(data: data) else { return }
                
                
                let weatherDict = json["weather"].array?.first?.dictionaryValue
                
                let date = json["dt"].doubleValue
                
                let sunrise = json["sys"]["sunrise"].doubleValue
                let sunset = json["sys"]["sunset"].doubleValue
                
                let isNight = sunrise > date || date > sunset
                
                let currentWeather = CurrentWeather(cityName: json["name"].string,
                                                    currentTemp: json["main"]["temp"].doubleValue,
                                                    description: weatherDict?["description"]?.string,
                                                    iconId: weatherDict?["icon"]?.string,
                                                    code: (weatherDict?["id"]!.intValue)!,
                                                    isNight: isNight)
                print(currentWeather)
                completion(currentWeather)
            }
            
        }.resume()
    }
    
    public func getForecastForLastWeatherLocation(completion: @escaping ([ForecastItem]) -> Void) {
        if let location = self.lastWeatherLocation {
            self.getForecastFor(lat: location.coordinate.latitude,
                                lon: location.coordinate.longitude,
                                completion: completion)
        }
    }
    
    public func getForecastFor(location: CLLocation,
                               completion: @escaping ([ForecastItem]) -> Void) {
        self.getForecastFor(lat: location.coordinate.latitude,
                            lon: location.coordinate.longitude,
                            completion: completion)
    }
    
    public func getForecastFor(lat: Double, lon: Double,
                               completion: @escaping ([ForecastItem]) -> Void) {
        
        
        let forecastUrlString = "\(self.baseUrl)/forecast/daily?lat=\(lat)&lon=\(lon)&appid=\(self.apiKey)&units=metric"
        let urlRequest = URLRequest(url: URL(string: forecastUrlString)!)
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                guard let data = data,
                      let json = try? JSON(data: data),
                      let jsonForecastItemsList = json["list"].array else { return }
                
                var forecastItems = [ForecastItem]()
                
                for jsonForecastItem in jsonForecastItemsList {
                    let weatherDict = jsonForecastItem["weather"].array?.first?.dictionary
                    let forecastItem = ForecastItem(weatherDescription: weatherDict?["description"]?.string,
                                                    maxTemp: jsonForecastItem["temp"]["max"].doubleValue,
                                                    minTemp: jsonForecastItem["temp"]["min"].doubleValue,
                                                    date: Date(timeIntervalSince1970: jsonForecastItem["dt"].doubleValue),
                                                    iconId: weatherDict?["icon"]?.string)
                    
                    forecastItems.append(forecastItem)
                }
                completion(forecastItems)
            }
        }.resume()
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
            DispatchQueue.main.async {
                try? data.write(to: self.getDocumentsDirectory().appendingPathComponent(iconId))
                completion(data)
            }
        }.resume()
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
