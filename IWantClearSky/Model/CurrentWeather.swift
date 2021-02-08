//
//  CurrentWeather.swift
//  IWantClearSky
//
//  Created by Anton Novoselov on 06.02.2021.
//

import Foundation

struct CurrentWeather: WeatherItem {
    // MARK: - PROPERTIES
    let cityName: String?
    let currentTemp: Double?
    let description: String?
    let iconId: String?
    let code: Int?
    let isNight: Bool
    
    // MARK: - CACHE
    public static func loadFromCache() -> CurrentWeather? {
        guard let data = UserDefaults.standard.object(forKey: SavedCurrentWeather) as? Data else {
            return nil
        }
        return try? JSONDecoder().decode(CurrentWeather.self, from: data)
    }
    
    public func saveToCache() {
        do {
            let data = try JSONEncoder().encode(self)
            UserDefaults.standard.set(data, forKey: SavedCurrentWeather)
        } catch {
            print(error)
        }
    }
}


