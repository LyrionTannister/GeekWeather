//
//  Weather.swift
//  GeekWeather
//
//  Created by Mad Brains on 29.06.2020.
//  Copyright © 2020 GeekTest. All rights reserved.
//

import Foundation
import RealmSwift

class Weather: Object, Decodable {
    
    @objc dynamic var id: String = ""
    @objc dynamic var date: Double = 0
    
    @objc dynamic var temperature: Double = 0
    @objc dynamic var pressure: Double = 0
    
    @objc dynamic var icon: String = ""
    @objc dynamic var textDescription: String = ""
    
    enum CodingKeys: String, CodingKey {
        case date = "dt"
        case main
        case weather
    }
    
    enum MainKeys: String, CodingKey {
        case temperature = "temp"
        case pressure
    }
    
    enum WeatherKeys: String, CodingKey {
        case icon
        case textDescription = "description"
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.date = try values.decode(Double.self, forKey: .date)
                
        let mainValues = try values.nestedContainer(keyedBy: MainKeys.self,
                                                   forKey: .main)
        self.temperature = try mainValues.decode(Double.self, forKey: .temperature)
        self.pressure = try mainValues.decode(Double.self, forKey: .pressure)
        
        var weatherValues = try values.nestedUnkeyedContainer(forKey: .weather)
        let firstWeatherValues = try weatherValues.nestedContainer(keyedBy: WeatherKeys.self)
        self.icon = try firstWeatherValues.decode(String.self, forKey: .icon)
        self.textDescription = try firstWeatherValues.decode(String.self,
        forKey: .textDescription)
        
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
