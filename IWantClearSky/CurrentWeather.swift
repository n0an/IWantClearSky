//
//  CurrentWeather.swift
//  IWantClearSky
//
//  Created by Anton Novoselov on 06.02.2021.
//

import Foundation

struct CurrentWeather: WeatherItem {
    var cityName: String?
    var currentTemp: Double
    var description: String?
    var iconId: String?
    var code: Int
    var isNight: Bool
    
    public static func loadFromCache() -> CurrentWeather? {
        guard let data = UserDefaults.standard.object(forKey: savedCurrentWeather) as? Data else {
            return nil
        }
        return try? JSONDecoder().decode(CurrentWeather.self, from: data)
    }
    
    func saveToCache() {
        do {
            let data = try JSONEncoder().encode(self)
            UserDefaults.standard.set(data, forKey: savedCurrentWeather)
        } catch {
            print(error)
        }
    }
}


