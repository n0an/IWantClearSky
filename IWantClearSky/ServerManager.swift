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
    var lastSearchedCity: String?
    
    public static let shared = ServerManager()
    private init() {}
    
    public func getCurrentWeatherFor(locationName: String,
                                     completion: @escaping (CurrentWeather) -> Void) {
        let currentWeatherUrl = "\(self.baseUrl)/weather?q=\(locationName)&appid=\(self.apiKey)&units=metric"
        let urlRequest = URLRequest(url: URL(string: currentWeatherUrl)!)
        self.getCurrentWeartherWithURLRequest(urlRequest, completion: completion)
    }
    
    private func getCurrentWeartherWithURLRequest(_ urlRequest: URLRequest,
                                                  short: Bool = false,
                                                  completion: @escaping (CurrentWeather) -> Void) {
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                guard let data = data,
                      let json = try? JSON(data: data) else { return }
                
                let responseCode = json["cod"].intValue
                
                if responseCode == 404 {
                    print("city not found")
                    return
                }
                
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
                
                currentWeather.saveToCache()
                
//                UserDefaults.standard.setValue(currentWeather.toDict, forKey: savedCurrentWeather)

                print(currentWeather)
                completion(currentWeather)
            }
            
        }.resume()
    }
    
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
                
                
                currentWeather.saveToCache()
                
                
                print(currentWeather)
                completion(currentWeather)
            }
            
        }.resume()
    }
    
    public func getForecastForLastSearched(completion: @escaping ([ForecastItem]) -> Void) {
        if let lastSearchedCity = self.lastSearchedCity {
            self.getForecastFor(city: lastSearchedCity, completion: completion)
        } else if let location = self.lastWeatherLocation {
            self.getForecastFor(lat: location.coordinate.latitude,
                                lon: location.coordinate.longitude,
                                completion: completion)
        }
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
    
    public func getForecastFor(city: String,
                               completion: @escaping ([ForecastItem]) -> Void) {
        
        
        let forecastUrlString = "\(self.baseUrl)/forecast/daily?q=\(city)&appid=\(self.apiKey)&units=metric"
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
                
                do {
                    let data = try JSONEncoder().encode(forecastItems)
                    UserDefaults.standard.set(data, forKey: savedForecast)
                } catch {
                    print(error)
                }
                
                completion(forecastItems)
            }
        }.resume()
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
                
                do {
                    let data = try JSONEncoder().encode(forecastItems)
                    UserDefaults.standard.set(data, forKey: savedForecast)
                } catch {
                    print(error)
                }
                
                
                completion(forecastItems)
            }
        }.resume()
    }
    
//    public static func loadFromCache() -> ForecastItem? {
//        guard let data = UserDefaults.standard.object(forKey: savedForecast) as? Data else {
//            return nil
//        }
//        return try? JSONDecoder().decode(ForecastItem.self, from: data)
//    }
//
//    func saveToCache() {
//        do {
//            let data = try JSONEncoder().encode(self)
//            UserDefaults.standard.set(data, forKey: savedForecast)
//        } catch {
//            print(error)
//        }
//    }
    
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
