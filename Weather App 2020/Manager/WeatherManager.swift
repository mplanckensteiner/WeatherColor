//
//  WeatherManager.swift
//  Weather App 2020
//
//  Created by Miguel Planckensteiner on 20.07.20.
//  Copyright © 2020 Miguel Planckensteiner. All rights reserved.
//

import Foundation
import Alamofire

enum WeatherError: Error, LocalizedError {
    
    case unknown
    case invalidCity
    case custom(description: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCity:
            return "This is a invalid city, please try again"
        case .unknown:
            return "Hey this is a unknown error!"
        case .custom(let description):
            return description
        }
    }
}

struct WeatherManager {
    
    private let API_KEY = "USE YOUR KEY"
    private let cacheManager = CacheManager()
    
    
    func fetchWeather(lat: Double, lon: Double, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        
        let path = "https://api.openweathermap.org/data/2.5/weather?appid=%@&units=metric&lat=%f&&lon=%f"
        let urlString = String(format: path, API_KEY, lat, lon)
        handleRequest(urlString: urlString, completion: completion)
    }
    
    func fetchWeather(byCity city: String, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        
        let query = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city
        let path = "https://api.openweathermap.org/data/2.5/weather?q=%@&appid=%@&units=metric"
        let urlString = String(format: path, query, API_KEY)
        handleRequest(urlString: urlString, completion: completion)
        
    }
    
    private func handleRequest(urlString: String, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        AF.request(urlString)
            .validate()
            .responseDecodable(of: WeatherData.self, queue: .main, decoder: JSONDecoder()) { (response) in
                
            
            switch response.result {
            case .success(let weatherData):
                let model = weatherData.model
                self.cacheManager.cacheCity(cityName: model.countryName)
                completion(.success(model))
            case .failure(let error):
                if let err = self.getWeatherError(error: error, data: response.data) {
                    completion(.failure(err))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func getWeatherError(error: AFError, data: Data?) -> Error? {
        if error.responseCode == 404,
            let data = data,
            let failure = try? JSONDecoder().decode(WeatherDataFailure.self, from: data) {
            let message = failure.message
            return WeatherError.custom(description: message)
        } else {
            return nil
        }
    }
}
