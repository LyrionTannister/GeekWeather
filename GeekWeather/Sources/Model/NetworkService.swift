//
//  NetworkService.swift
//  GeekWeather
//
//  Created by Mad Brains on 29.06.2020.
//  Copyright © 2020 GeekTest. All rights reserved.
//

import Foundation
//import Alamofire
//import SwiftyJSON
import PromiseKit

class NetworkService {
    
    static let sessionURL: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        let session = URLSession(configuration: config)
        return session
    }()
    
    func weatherPromise(for city: String) -> Promise<Weather>  {
        
        var urlConstructor = URLComponents()
        urlConstructor.scheme = "https"
        urlConstructor.host = "api.openweathermap.org"
        urlConstructor.path = "/data/2.5/weather"
        urlConstructor.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "appId", value: "8b32f5f2dc7dbd5254ac73d984baf306"),
        ]
        let request = URLRequest(url: urlConstructor.url!)
 
        return Promise { resolver in
            NetworkService.sessionURL.dataTask(with: request) {
                (data, response, error) in
                if let error = error {
                    resolver.reject(error)
                }
                guard let data = data else { return }
                do {
                    let weather = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    resolver.fulfill(weather.list.first!)
                } catch let jsonError {
                    resolver.reject(jsonError)
                }

            }.resume()
        }
    }
    
    func weatherImagePromise(iconName: String) -> Promise<UIImage> {
        guard let url = URL(string: "https://api.openweathermap.org/img/w/\(iconName).png") else {
            return Promise.value(UIImage(named: "default_icon")!)
        }
        
        // Пользуемся расширением класса URLSession определенным в PromiseKit
        return URLSession.shared.dataTask(.promise, with: url)
            .then(on: DispatchQueue.global()) { response -> Promise<UIImage> in
                // В замыкании оператора then мы обязаны создать новый Promise
                let image = UIImage(data: response.data) ?? UIImage(named: "default_icon")!
                return Promise.value(image)
        }
        
    }
    
    func weatherImage(iconName: String, completionHandler: @escaping (Swift.Result<UIImage, Error>) -> Void) {
        guard let url = URL(string: "https://api.openweathermap.org/img/w/\(iconName).png") else {
            completionHandler(.failure(NSError()))
            
            return
        }
        
        NetworkService.sessionURL.dataTask(with: url) { (data, response, error) in
            if let error = error {
                return completionHandler(.failure(error))
            }
            guard let uData = data else {
                return completionHandler(.failure(NSError()))
            }
                let image = UIImage(data: uData)
                completionHandler(.success(image!))
        }.resume()
    }
    
}
