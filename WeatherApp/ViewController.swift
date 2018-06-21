//
//  ViewController.swift
//  WeatherApp
//
//  Created by TakahashiNobuhiro on 2018/06/20.
//  Copyright © 2018 feb19. All rights reserved.
//

import UIKit
import CoreLocation

struct Weather: Decodable {
    let id: Int64
    let main: String
    let description: String
    let icon: String
}

struct WeatherData: Decodable {
    let weather: [Weather]
}


class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var weatherImageView: UIImageView!
    // https://home.openweathermap.org/api_keys
    // https://openweathermap.org/current#geo
    let openWeatherMapUrlString = "http://api.openweathermap.org/data/2.5/weather?q=Tokyo&appid=(appId)"
    var locationManager = CLLocationManager()
    
    func openWeatherGeoUrlString(lat: CLLocationDegrees, lon: CLLocationDegrees) -> String {
        return "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=(appId)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        activityIndicatorView.startAnimating()
//        getTokyoWeather()
        getCurrentLocationWeather()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCurrentLocationWeather() {
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1
        
        locationManager.headingOrientation = .portrait
        locationManager.headingFilter = 1
        locationManager.startUpdatingHeading()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.stopUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationData = locations.last
        
        if let lat = locationData?.coordinate.latitude, let lon = locationData?.coordinate.longitude {
            print("\(lat):\(lon)")
            
            getCurrentLocationWeather(lat: lat, lon: lon)
            
            locationManager.stopUpdatingLocation()
        }
    }
    
    func getCurrentLocationWeather(lat: CLLocationDegrees, lon: CLLocationDegrees){
        let url = NSURL(string: openWeatherGeoUrlString(lat: lat, lon: lon))!
        // GET
        let task = URLSession.shared.dataTask(with: url as URL, completionHandler: {data, response, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data, let json = String(data: data, encoding: .utf8) {
                print(json)
                print("----------")
                var weatherData: WeatherData!
                let decoder = JSONDecoder()
                do {
                    weatherData = try decoder.decode(WeatherData.self, from: data)
                } catch let error {
                    print(error as NSError)
                }
                print(weatherData)
                self.setWeatherImage(icon: (weatherData.weather.first?.icon)!)
                
            }
        })
        task.resume()
        
    }

    func getTokyoWeather(){
        let url = NSURL(string: self.openWeatherMapUrlString)!
        // GET
        let task = URLSession.shared.dataTask(with: url as URL, completionHandler: {data, response, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data, let json = String(data: data, encoding: .utf8) {
                print(json)
                print("----------")
                var weatherData: WeatherData!
                let decoder = JSONDecoder()
                do {
                    weatherData = try decoder.decode(WeatherData.self, from: data)
                } catch let error {
                    print(error as NSError)
                }
                print(weatherData)
                self.setWeatherImage(icon: (weatherData.weather.first?.icon)!)

            }
        })
        task.resume()
        
    }
    
    func loadWebImage(url: URL, completion: @escaping (_ image: UIImage) -> Void) {
        let session = URLSession(configuration: .default)
        let downloadTask = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let res = response as? HTTPURLResponse {
                    print("\(res.statusCode)")
                    if let imageData = data {
                        let image = UIImage(data: imageData)
                        completion(image!)
                    }
                }
            }
        }
        downloadTask.resume()
    }
    
    func setWeatherImage(icon: String) {
        // https://openweathermap.org/weather-conditions
        let url = URL(string: "http://openweathermap.org/img/w/\(icon).png")!
        loadWebImage(url: url) { (image) in
            DispatchQueue.main.async {
                
                self.activityIndicatorView.stopAnimating()
                
                self.activityIndicatorView.isHidden = true
                self.weatherImageView.image = image
            }
        }
        
    }

}

