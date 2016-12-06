//
//  LocationFetcher.swift
//  GoBus
//
//  Created by Pritesh Nandgaonkar on 12/6/16.
//  Copyright © 2016 Pritesh Nandgaonkar. All rights reserved.
//

import Foundation
import MapKit

enum Result<T, U: Error> {
    case success(T)
    case failure(U)
}

class LocationFetcher: NSObject {
    
    let locationManager: CLLocationManager
    static let sharedInstance: LocationFetcher = LocationFetcher()
    
    enum LocationError: Error {
        case locationUnknown
        case permissionDenied
        case network
        case unkownError
        
        init(with error: CLError) {
            switch error.code {
            case .locationUnknown:
                self = .locationUnknown
            case .denied:
                self = .permissionDenied
            case .network:
                self = .network
            default:
                self = .unkownError
            }
        }
        
        var errorDescription: String {
            var errorString = ""
            switch self {
            case .locationUnknown:
                errorString = "Unknown Location"
            case .permissionDenied:
                errorString = "Permission Denied"
            case .network:
                errorString = "Network Error"
            default:
                errorString = "Internal Error"
            }
            
            return errorString
        }
    }
    
    var completions: [(Result<CLLocationCoordinate2D, LocationError>) -> ()]
    
    private override init() {
        locationManager = CLLocationManager()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        completions = [(Result<CLLocationCoordinate2D, LocationError>) -> ()]()
        super.init()
        locationManager.delegate = self
        }
    
    public func fetchCurrentLocation(with completion:@escaping (Result<CLLocationCoordinate2D, LocationError>) -> ()) {
        completions.append(completion)
        locationManager.startUpdatingLocation()
    }
}

extension LocationFetcher: CLLocationManagerDelegate {
   
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation()
        var result: Result<CLLocationCoordinate2D, LocationError>
        
        if let coordinate = locations.last?.coordinate {
            result = Result.success(coordinate)
        }
        else {
            result = Result.failure(LocationError.unkownError)
        }
        
        for completion in completions {
            completion(result)
        }
        completions.removeAll()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        locationManager.stopUpdatingLocation()
        var result: Result<CLLocationCoordinate2D, LocationError>
        
        defer {
            for completion in completions {
                completion(result)
            }
            completions.removeAll()
        }
        
        guard let error = error as? CLError else {
            result = Result.failure(.unkownError)
            return
        }
        
        result = Result.failure(LocationError(with: error))
    }
}
