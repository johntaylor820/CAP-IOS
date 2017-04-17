//
//  LocationViewController.swift
//  Capture
//
//  Created by Mathias Palm on 2016-04-19.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol LocationDelegate {
    func addedLocation(_ coordinate:CLLocationCoordinate2D?, name:String?)
}


class LocationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var searchingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    var mapView = MKMapView()
    var matchingItems:[MKMapItem] = []
    let locationManager = CLLocationManager()
    var refreshControl: UIRefreshControl!
    var delegate:LocationDelegate?
    
    var currentLocation:CLLocation? = nil {
        didSet {
            if let nam = locationName {
                self.search(nam)
            } else {
                geoLocation(currentLocation!, completion: {
                    name in
                    self.search(name)
                })
            }
        }
    }
    var locationName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestLocation()
            searchingIndicator.startAnimating()
        }
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(LocationViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        searchTableView.addSubview(self.refreshControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(_ sender:AnyObject) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse && currentLocation == nil {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if let location = locations.first {
            currentLocation = location
        }
    }
    
    func geoLocation(_ location:CLLocation, completion:@escaping (String) -> ()) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: {
            (placemarks, error) -> Void in
            if let marks = placemarks {
                if let city = marks[0].addressDictionary!["City"] as? NSString {
                    var loc = city as String
                    if let country = marks[0].country {
                        loc = "\(loc), \(country)"
                    }
                    completion(loc)
                }
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchBarText = searchBar.text else { return }
        search(searchBarText)
    }
    
    func search(_ serchTerm:String) {
        locationName = serchTerm
        let request = MKLocalSearchRequest()
        if let current = currentLocation {
            let span = MKCoordinateSpanMake(50000, 50000)
            let region = MKCoordinateRegion(center: current.coordinate, span: span)
            mapView.setRegion(region, animated: false)
            request.region = mapView.region

        }
        request.naturalLanguageQuery = serchTerm
        let search = MKLocalSearch(request: request)
        if search.isSearching {
            search.cancel()
        }
        search.start { response, err in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.matchingItems.insert(MKMapItem(), at: 0)
            self.searchTableView.reloadData()
            self.searchingIndicator.stopAnimating()
            self.searchingIndicator.isHidden = true
            self.refreshControl.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell!
        if (indexPath as NSIndexPath).row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "currentLoc", for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
            let selectedItem = matchingItems[(indexPath as NSIndexPath).row].placemark
            cell.textLabel?.text = selectedItem.name
            cell.detailTextLabel?.text = parseAddress(selectedItem)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchTableView.isUserInteractionEnabled = false
        searchBar.isUserInteractionEnabled = false
        if (indexPath as NSIndexPath).row == 0 {
            geoLocation(self.currentLocation!, completion: {
                name in
                self.delegate?.addedLocation(self.currentLocation?.coordinate, name: name)
                _ = self.navigationController?.popViewController(animated: true)
            })
        } else {
            let selectedItem = matchingItems[(indexPath as NSIndexPath).row].placemark
            delegate?.addedLocation(selectedItem.coordinate, name: selectedItem.name)
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    func parseAddress(_ selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "location" {

        }
    }
}
