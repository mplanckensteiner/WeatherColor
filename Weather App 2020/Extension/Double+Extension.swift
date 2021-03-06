//
//  Double+Extension.swift
//  Weather App 2020
//
//  Created by Miguel Planckensteiner on 20.07.20.
//  Copyright © 2020 Miguel Planckensteiner. All rights reserved.
//

import Foundation

extension Double {
    func toString() -> String {
        return String(format: "%.0f", self)
    }
    
    func toInt() -> Int {
        return Int(self)
    }
    
}
