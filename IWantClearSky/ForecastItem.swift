//
//  ForecastItem.swift
//  IWantClearSky
//
//  Created by Anton Novoselov on 06.02.2021.
//

import Foundation

struct ForecastItem: WeatherItem {
    let weatherDescription: String?
    let maxTemp: Double
    let minTemp: Double
    let date: Date
    let iconId: String?
    
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
}

protocol WeatherItem: Codable {
    func prepareTemperatureStr(temp: Double) -> String
}

extension WeatherItem {
    func prepareTemperatureStr(temp: Double) -> String {
        let temp = Int(temp)
        var tempStr = "\(temp)º"
        if temp > 0 {
            tempStr = "+\(tempStr)"
        }
        return tempStr
    }
}
