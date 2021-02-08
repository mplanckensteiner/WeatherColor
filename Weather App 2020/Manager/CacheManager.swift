//
//  CacheManager.swift
//  Weather App 2020
//
//  Created by Miguel Planckensteiner on 12.08.20.
//  Copyright © 2020 Miguel Planckensteiner. All rights reserved.
//

import Foundation


struct CacheManager {
    
    private let vault = UserDefaults.standard
    
    enum Key: String {
        case city
    }
    
    
    func cacheCity(cityName: String) {
        vault.set(cityName, forKey: Key.city.rawValue)
    }
    
    
    func getCachedCity() -> String? {
        vault.value(forKey: Key.city.rawValue) as? String
    }
}
