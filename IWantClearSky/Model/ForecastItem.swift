//
//  ForecastItem.swift
//  IWantClearSky
//
//  Created by Anton Novoselov on 06.02.2021.
//

import Foundation

struct ForecastItem: WeatherItem {
    // MARK: - PROPERTIES
    let weatherDescription: String?
    let maxTemp: Double?
    let minTemp: Double?
    let date: Date?
    let iconId: String?
    
    // MARK: - CACHE
    public static func loadForecastFromCache() -> [Self] {
        guard let data = UserDefaults.standard.object(forKey: savedForecast) as? Data else {
            return []
        }
        if let forecastItems = try? JSONDecoder().decode([ForecastItem].self, from: data) {
            return forecastItems
        }
        return []
    }
    
    public static func saveForecastToCache(forecastItems: [Self]) {
        do {
            let data = try JSONEncoder().encode(forecastItems)
            UserDefaults.standard.set(data, forKey: savedForecast)
        } catch {
            print(error)
        }
    }
    
    public static func invalidateForecastCache() {
        UserDefaults.standard.removeObject(forKey: savedForecast)
    }
}
