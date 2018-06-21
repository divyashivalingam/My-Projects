//
//  LocationMapView.swift
//  PhotoLocation
//
//  Copyright © 2018 divya. All rights reserved.
//

import Foundation
import MapKit
import CoreData
import CoreLocation

protocol LocationMapViewDelegate {
    func addAnnotationForLocation(locationPlacemark:MKPlacemark, locationName: String)
}
class LocationMapView : UIViewController {
    
    @IBOutlet weak var photolocationMapVw: MKMapView!
    let locationManager: CLLocationManager! = nil
    var locationMapArray : NSMutableArray!
    let theRegionRadius : CLLocationDistance = 11000

    var locationSearchController:UISearchController!
    var locationAnnotation:MKAnnotation!
   
    var error:NSError!
    var locationPointAnnotation:MKPointAnnotation!
    var locationPinAnnotationView:MKPinAnnotationView!
    
    var locationSearchRequest:MKLocalSearchRequest!
    var locationSearch:MKLocalSearch!
    var locationSearchResponse:MKLocalSearchResponse!
    
    var lcoationsSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        photolocationMapVw.delegate = self
        self.title = "Map"
        
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()
        
//        self.navigationItem.hidesBackButton = true
        
        self.setUp();
        
    }
    
    func setUp(){
        let initialLocation = LocationManager.currentLocation  
        self.centerTheMapToRegion(cllocation: initialLocation);

        let fetchedLocations = LocationManager.fetchAllCustomLocations()
        if fetchedLocations.count > 0 {
            for location in fetchedLocations as! [Location]{
                locationMapArray .add(location)
            }
        }
        //add pins for all the fetched locations
        for locationValue in self.locationMapArray{
            let location = locationValue as! Location
            photolocationMapVw.addAnnotation(location)
        }
        self.setUpSearchController();

    }
    
    func setUpSearchController(){
        let locationSearchTableView = storyboard!.instantiateViewController(withIdentifier: "searchTableViewID") as! SearchTableView
        lcoationsSearchController = UISearchController(searchResultsController: locationSearchTableView)
        lcoationsSearchController?.searchResultsUpdater = locationSearchTableView
        lcoationsSearchController?.hidesNavigationBarDuringPresentation = false

        locationSearchTableView.locationMapView = photolocationMapVw
        locationSearchTableView.locationMapViewDelegate = self
        
        let searchBar = lcoationsSearchController!.searchBar
        searchBar.placeholder = "Search to add new location"
        searchBar.sizeToFit()
        
        navigationItem.titleView = lcoationsSearchController?.searchBar
        definesPresentationContext = true
    }
    
    func saveLocation(location: Location){
        if LocationManager.addLocation(location: location){
            print("Save success")
        }
    }
    
    func centerTheMapToRegion(cllocation: CLLocation) {
        let locationCoordinate = MKCoordinateRegionMakeWithDistance(cllocation.coordinate, theRegionRadius, theRegionRadius)
        photolocationMapVw.setRegion(locationCoordinate, animated: true)
    }
    
    @objc func listTapped(){
        
        let listView:LocationList = storyboard?.instantiateViewController(withIdentifier: "locationListID") as! LocationList
        self.navigationController?.pushViewController(listView, animated: false)
    }

}

extension LocationMapView : MKMapViewDelegate {
    //    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    //        mapView.setCenter(userLocation.coordinate, animated: true)
    //    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotationA = annotation as? Location else {return nil}
        let annotationIdentifier = "annotationID"
        
        var annotationView : MKAnnotationView
        
        if let dequedAnnotationView = photolocationMapVw.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier){
            dequedAnnotationView.annotation = annotationA
            annotationView = dequedAnnotationView
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else{
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView.canShowCallout = true
            annotationView.calloutOffset = CGPoint(x: -5, y: 5)
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let photoDetail:PhotoDetailView = storyboard?.instantiateViewController(withIdentifier: "photoDetailViewID") as! PhotoDetailView
        
        let location = view.annotation as! Location
        let fetchedLocations = LocationManager.fetchLocationBy(queryStr: location.locationName!)
        
        for fetchedLocation in fetchedLocations as! [NSManagedObject] {
            location.notes = fetchedLocation.value(forKey: "notes") as! String
        }
        
        photoDetail.locationDetail = location
        self.navigationController?.pushViewController(photoDetail, animated: true)
    }
    
}

extension LocationMapView : CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
            if let location = locations.first {
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                photolocationMapVw.setRegion(region, animated: true)
            }
        }
    }
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError error:: \(error)")
    }
}

extension LocationMapView: LocationMapViewDelegate {
    
    func addAnnotationForLocation(locationPlacemark:MKPlacemark, locationName: String){
        selectedPin = locationPlacemark
        photolocationMapVw.removeAnnotations(photolocationMapVw.annotations)
        
        let locationObj = Location(title:  locationName, locationName: locationName, coordinate: CLLocationCoordinate2D(latitude: locationPlacemark.coordinate.latitude , longitude: locationPlacemark.coordinate.longitude ), notes: "", isEditable: true)
        
        photolocationMapVw.addAnnotation(locationObj)
        
        //save this custom location added by user
        self.saveLocation(location: locationObj);
       
        self.centerTheMapToRegion(cllocation: CLLocation(latitude: locationPlacemark.coordinate.latitude, longitude: locationPlacemark.coordinate.longitude))
    }
}
