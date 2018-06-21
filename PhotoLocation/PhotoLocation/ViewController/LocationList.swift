//
//  LocationList.swift
//  PhotoLocation
//
//  Copyright © 2018 divya. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import CoreLocation

class LocationList : UICollectionViewController, XMLParserDelegate{
    
    var locationsArray:NSMutableArray = NSMutableArray()
    let photoLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var cllocationManager : CLLocationManager?
    
    @IBOutlet weak var sortSegment: UISegmentedControl!
    var currentLocation2D:CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "List"
        
        cllocationManager = CLLocationManager()
        cllocationManager?.delegate = self;
        cllocationManager?.desiredAccuracy = kCLLocationAccuracyBest
        cllocationManager?.requestAlwaysAuthorization()
        cllocationManager?.startUpdatingLocation()
       
        LocationManager.delegate = self
        self.getLocation();
//        self.navigationItem.hidesBackButton = true

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Map", style: .plain, target: self, action: #selector(addTapped));
//        retrieveLocations();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        locationsArray = []
        retrieveLocations();
        self.collectionView?.reloadData()
    }
    
    func retrieveLocations(){
        
        LocationManager.retrieveLocationsFromURL()
        
        //also load custom locations added by user
        let customLocations = LocationManager.fetchAllCustomLocations()
        updateLocationsArray(array: customLocations)
        
    }
    
    func updateLocationsArray(array : NSArray){
        if array.count > 0 {
            for location in array as! [Location]{
                locationsArray .add(location)
            }
            self.onTappingSort(0)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func addTapped(){

        let mapView:LocationMapView = storyboard?.instantiateViewController(withIdentifier: "locationMapViewID") as! LocationMapView
        mapView.locationMapArray = locationsArray
        self.navigationController?.pushViewController(mapView, animated: false)
    }
    
    @IBAction func onTappingSort(_ sender: Any) {
        var sortedLocations = NSArray()
        var sortBy = String()
        switch (sender as AnyObject).selectedSegmentIndex {
            case 0:
                sortBy = "Name"
            case 1:
                sortBy = "Distance"
            default:
                sortBy = "Name"
            }
   
        
        sortedLocations = LocationManager.sortLocations(by: sortBy, locations: locationsArray)
        locationsArray = (sortedLocations as NSArray).mutableCopy() as! NSMutableArray

        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    func getLocation(){
        let filePath = self.getFilePath(fileName: "Location")
        
        let data = NSData(contentsOfFile: filePath!)
        let parser = XMLParser(data: data! as Data)
        parser.delegate = self
        
        let success = parser.parse()
        if success{
            print ("parse success");
        }
    }
    
    func getFilePath(fileName: String) -> String? {
        return Bundle.main.path(forResource: fileName, ofType: "gpx")
    }
   
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "trkpt" || elementName == "wpt" {
            let latitute = CLLocationDegrees(attributeDict["lat"]!)
            let longitude = CLLocationDegrees(attributeDict["lon"]!)
            LocationManager.currentLocation = CLLocation(latitude: latitute!, longitude: longitude!)
        }
    }
}

extension LocationList : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation2D = manager.location!.coordinate
    }
}
extension LocationList : LocationManagerDelegate{

    func didCompleteFetch(fetchedLocations: NSArray) {
        updateLocationsArray(array: fetchedLocations)
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
}

extension LocationList {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locationsArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        photoCell.backgroundColor = UIColor.lightGray
        
        let location = locationsArray.object(at: indexPath.row) as! Location
        
        photoCell.photoImg.image = UIImage(named: "image1")
        photoCell.photoTitle.text = location.locationName
        
        return photoCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "photoHeader", for: indexPath)
        return headerView
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photoDetail:PhotoDetailView = storyboard?.instantiateViewController(withIdentifier: "photoDetailViewID") as! PhotoDetailView
        photoDetail.locationDetail = locationsArray.object(at: indexPath.row) as? Location
        self.navigationController?.pushViewController(photoDetail, animated: true)
    }
    
}
