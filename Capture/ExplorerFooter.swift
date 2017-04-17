//
//  ExplorerFooter.swift
//  Capture
//
//  Created by Mathias Palm on 2016-08-24.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ExplorerFooter: UICollectionReusableView {
    @IBOutlet weak var explorerMapView: MKMapView!
    @IBOutlet weak var choperHeightConstraint: NSLayoutConstraint!
    let locationManager = CLLocationManager()
    var currentLocation:CLLocation?
    
    var locations: [ExplorerAnnotation]?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        choperHeightConstraint.constant = 1/UIScreen.main.scale
        layoutIfNeeded()
    }
    
    func setup() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestLocation()
        }
        getLocations()
    }
    
    func getLocations() {
        locations = [ExplorerAnnotation(dictionary: ["lat": 59.853506 as AnyObject, "long" : 17.616594 as AnyObject, "likes" : 72 as AnyObject, "id" : 2 as AnyObject])]
        
    }
    
    func addLocations() {
        if let locations = locations {
            for location in locations {
                explorerMapView.addAnnotation(location)
            }
        }
    }
}
extension ExplorerFooter: MKMapViewDelegate, CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse && currentLocation == nil {
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if let location = locations.first {
            currentLocation = location
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            explorerMapView.tintColor = UIColor(red: 250/255, green: 33/255, blue: 86/255, alpha: 1.0)
            explorerMapView.setRegion(region, animated: false)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        if annotation is ExplorerAnnotation {
            let customAnnotation = annotation as? ExplorerAnnotation
            mapView.translatesAutoresizingMaskIntoConstraints = false
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "CustomAnnotation") as MKAnnotationView!
            
            if (annotationView == nil) {
                annotationView = customAnnotation?.annotationView()
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        } else {
            return nil
        }
    }
}
