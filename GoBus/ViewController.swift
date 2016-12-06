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

    let initialLocation = CLLocation(latitude: 24.44072, longitude: 54.44392)
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerMapOnLocation(location: initialLocation.coordinate)
        fetchCurrentLocation()
        mapView.delegate = self

        Alamofire.request("http://54.255.135.90/busservice/api/v1/bus-stops/radius?lat=24.44072&lon=54.44392&radius=500").responseArray(BusStop.self) { (response) in
            switch response.result {
            case .success(let people):
                self.mapView.addAnnotation(people.first!)
                print("Found Busstop: \(people)")
            case .failure(let error):
                print("Error'd: \(error)")
            }
        }
    }
    
    func fetchCurrentLocation() {
        SVProgressHUD.show(withStatus: "Fetching Current Location...")
        
        LocationFetcher.sharedInstance.fetchCurrentLocation { [weak self] (result: Result<CLLocationCoordinate2D, LocationFetcher.LocationError>) in
            SVProgressHUD.dismiss()
            
            switch result {
            case .success(let coordinates):
//                self?.centerMapOnLocation(location: coordinates)
                print("Current Location \(coordinates)")
            case .failure(let error):
                self?.handle(error: error)
            }
        }
    }
    
    func handle(error: LocationFetcher.LocationError) {
        
        let controller = Utility.showAlertViewController(withTitle: "GoBus", message: error.errorDescription, buttonTitle: "Retry", cancelButtonTitle: "Cancel", buttonAction: { [weak self] in
            self?.fetchCurrentLocation()
        })
        present(controller, animated: true, completion: nil)
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
    
    // 1
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? BusStop {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type:.detailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
}
