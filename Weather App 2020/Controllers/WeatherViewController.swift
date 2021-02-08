//
//  ViewController.swift
//  Weather App 2020
//
//  Created by Miguel Planckensteiner on 20.07.20.
//  Copyright © 2020 Miguel Planckensteiner. All rights reserved.
//

import UIKit
import SkeletonView
import CoreLocation

protocol WeatherViewControllerDelegate: class {
    func didUpdateWeatherFromSearch(model: WeatherModel)
}

class WeatherViewController: UIViewController {
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var cityTextField: UITextField!
    
    weak var delegate: WeatherViewControllerDelegate?
    
    private let weatherManager = WeatherManager()
    private let cacheManager = CacheManager()
    private let defaultCity = "berlin"
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cityTextField.addTarget(self, action: #selector(onReturn), for: UIControl.Event.editingDidEndOnExit)
        let city = cacheManager.getCachedCity() ?? defaultCity
        fetchWeather(byCity: city)

    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           cityTextField.becomeFirstResponder()
       }
    
    //MARK: - FUNCTIONS
    
    private func fetchWeather(byLocation location: CLLocation) {
        showAnimation()
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        weatherManager.fetchWeather(lat: lat, lon: lon) { [weak self] (result) in
            guard let this = self else { return }
            this.handleResult(result)
        }
    }
    
    private func fetchWeather(byCity city: String) {
        showAnimation()
        weatherManager.fetchWeather(byCity: city) { [weak self] (result) in
            guard let this = self else { return }
            this.handleResult(result)
        }
    }
    
    private func handleResult(_ result: Result<WeatherModel, Error>) {
        switch result {
        case .success(let model):
            updateView(with: model)
        case .failure(let error):
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        hideAnimation()
        conditionImageView.image = UIImage(named: "imSad")
        cityLabel.text = ""
        temperatureLabel.text = "Oops!"
        conditionLabel.text = "Something went wrong. Please try again."
    }
    
    private func updateView(with model: WeatherModel) {
        
        
        hideAnimation()
        
        temperatureLabel.text = model.temp.toString().appending("°C")
        conditionLabel.text = model.conditionDescription
        cityLabel.text = model.countryName
        
        conditionImageView.image = UIImage(named: model.conditionImage)
        backgroundImage.image = UIImage(named: model.conditionBackgroundImage)
        
        
    }
    private func hideAnimation() {
        temperatureLabel.hideSkeleton()
        conditionLabel.hideSkeleton()
        conditionImageView.hideSkeleton()
    }
    private func showAnimation() {
        conditionImageView.showAnimatedGradientSkeleton()
        temperatureLabel.showAnimatedGradientSkeleton()
        conditionLabel.showAnimatedGradientSkeleton()
    }
    
    private func showSearchError(text: String) {
           
        backgroundImage.image = UIImage(systemName: "snow")
           
       }
    
    private func handleSearch(query: String) {
        view.endEditing(true)
        weatherManager.fetchWeather(byCity: query) { [weak self] (result) in
            guard let this = self else {return}
            switch result {
            case .success(let model):
                this.handleSearchSuccess(model: model)
            case .failure(let error):
                this.showSearchError(text: error.localizedDescription)
            }
        }
    }
    
    private func handleSearchSuccess(model: WeatherModel) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.delegate?.didUpdateWeatherFromSearch(model: model)
            
        }
    }

    
    //MARK: - IBActions
    
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        default:
            promtForLocationPermission()
        }
    }
    
    @IBAction func onReturn() {
        self.cityTextField.resignFirstResponder()
        // do whatever you want...
        
        guard let query = cityTextField.text, !query.isEmpty else {
            showSearchError(text: "City Cannot be empty. Please Try Again!")
            
            return }
        handleSearch(query: query)
        fetchWeather(byCity: query)
    }
    
    private func promtForLocationPermission() {
        
        let alertController = UIAlertController(title: "Requires Location Permission", message: "Would you like to enable location permission in Settings?", preferredStyle: .alert)
        let enableAction = UIAlertAction(title: "Go to Settings", style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return}
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(enableAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            manager.stopUpdatingLocation()
            fetchWeather(byLocation: location)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        handleError(error)
    }
}
