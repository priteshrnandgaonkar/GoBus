//
//  ViewController.swift
//  GoBus
//
//  Created by Pritesh Nandgaonkar on 12/5/16.
//  Copyright © 2016 Pritesh Nandgaonkar. All rights reserved.
//

import UIKit
import AlamofireGloss
import Alamofire
import MapKit
import SVProgressHUD

class ViewController: UIViewController {

    var currentLocation = CLLocationCoordinate2D(latitude: 24.4702, longitude: 54.3726)
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "GoBus"
        fetchCurrentLocation()
        // Drop a pin
    }
    
    func fetchCurrentLocation() {
        SVProgressHUD.show(withStatus: "Fetching Current Location...")
        
        LocationFetcher.sharedInstance.fetchCurrentLocation { [weak self] (result: Result<CLLocationCoordinate2D, LocationFetcher.LocationError>) in
            SVProgressHUD.dismiss()
            guard let weakSelf = self else {
                return
            }
            switch result {
            case .success(let coordinates):
                // FIXME
//                weakSelf.currentLocation = coordinates
                weakSelf.updateMapWithBusStops(at: weakSelf.currentLocation)
            case .failure(let error):
                weakSelf.handle(error: error, withRetryBlock: { weakSelf.fetchCurrentLocation() })
            }
        }
    }
    
    func updateMapWithBusStops(at coordinate: CLLocationCoordinate2D) {
        centerMapOnLocation(location: coordinate)
        
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = coordinate
        dropPin.title = "You are here"
        mapView.addAnnotation(dropPin)
        
        getNearbyBusStops(from: coordinate, with: { [weak self] result in
            
            guard let weakSelf = self else {
                return
            }
            switch result {
            case .success(let busStops):
                weakSelf.mapView.showAnnotations(busStops, animated: true)
                
            case .failure(let error):
                weakSelf.handle(error: error, withRetryBlock: { weakSelf.updateMapWithBusStops(at: weakSelf.currentLocation)})
            }
        })
    }
    
    func getNearbyBusStops(from coordinate: CLLocationCoordinate2D, with completion:@escaping (Result<[BusStop], NetworkError>) -> ()) {
        
        let url = Constants.baseUrl + Constants.fetchBusStopsApiPath + "?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&radius=500"
        NetworkUtility.getJSONArray(url: url, withCompletion: { (result: Result<[JSON], NetworkError>) in
            
            switch result {
            case .success(let array):
                guard let busStops = [BusStop].from(jsonArray: array) else {
                    completion(Result.failure(NetworkError.parsingError))
                    return
                }
                completion(Result.success(busStops))
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {

        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? BusStop {
            let identifier = "bus-stop"
            var view: MKAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                 {
                view = dequeuedView
            } else {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            view.canShowCallout = true
            view.image = UIImage(named: "bus-stop")
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type:.detailDisclosure) as UIView
            view.annotation = annotation
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        guard let busStop = view.annotation as? BusStop else {
            return
        }
        let vc: BusListViewController = UIViewController.instantiateViewController(with: "BusListViewController")
        vc.busStop = busStop
        navigationController?.pushViewController(vc, animated: true)
    }
}
