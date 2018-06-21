//
//  LocationManager.swift
//  PhotoLocation
//
//  Copyright © 2018 divya. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

public protocol LocationManagerDelegate {
    func didCompleteFetch(fetchedLocations: NSArray)
}

struct Locations: Codable {
    var locations: [EachLocation]
    var updated: String
    
    init(locations: [EachLocation], updated: String) {
        self.locations = locations
        self.updated = updated
    }
}

struct EachLocation: Codable {
    var name: String
    var lat: Float
    var lng : Float
    
    init(name: String, lat:Float, lng: Float) {
        self.name = name
        self.lat = lat
        self.lng = lng
    }
}

class LocationManager : NSObject, XMLParserDelegate {
    
    static var delegate : LocationManagerDelegate?
    static var currentLocation = CLLocation()

    class func retrieveLocationsFromURL(){
        let defaultLocations = NSMutableArray()

        guard let jsonURL = URL(string: "http://bit.ly/test-locations")
            else {
                return
        }
        URLSession.shared.dataTask(with: jsonURL) { (data, response
            , error) in
            guard let data = data else {
                return
            }
            do {
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(Locations.self, from: data)
                
                for location: EachLocation in jsonData.locations {
                    
                    let locationObj = Location(title:  location.name , locationName: location.name , coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(location.lat), longitude: CLLocationDegrees(location.lng)), notes: location.name , isEditable: false)
                    
                    defaultLocations .add(locationObj)
                }
                delegate?.didCompleteFetch(fetchedLocations: defaultLocations)

                
            } catch let err {
                print("Json fetch error", err)
            }
            }.resume()        
    }
    
    class func addLocation(location :Location)-> Bool{
        let newLocation = CoreDataManager.managedObject
        
        newLocation.setValue(location.locationName, forKey: "locationName")
        newLocation.setValue(location.locationLatitude, forKey: "lat")
        newLocation.setValue(location.locationLongitude, forKey: "lng")
        newLocation.setValue(location.notes, forKey: "notes")
        newLocation.setValue(location.isEditable, forKey: "isEditable")
        
        if CoreDataManager.saveData(){
            return true
        }
        
        return false
    }
    
    class func saveLocation()->Bool{
        if CoreDataManager.saveData(){
            return true
        }
        else{
            return false
        }
    }
    
    class func fetchAllCustomLocations()-> NSMutableArray{
        let fetchedResults = CoreDataManager.fetchAllData()
        let fetchedLocations = NSMutableArray()
        for locationByUser in fetchedResults as! [NSManagedObject] {
            let locationObj = Location(title:  locationByUser.value(forKey: "locationName") as! String,
            locationName: locationByUser.value(forKey: "locationName") as! String,
            coordinate: CLLocationCoordinate2D(latitude: locationByUser.value(forKey: "lat") as! Double, longitude: locationByUser.value(forKey: "lng") as! Double), notes: locationByUser.value(forKey: "notes") as! String, isEditable: true)
        
            fetchedLocations .add(locationObj)
        }
        return fetchedLocations
    }
    
    class func fetchLocationBy(queryStr: String)->NSArray{
        return CoreDataManager.fetchResultsBy(query : "locationName",  string: queryStr) as! NSArray
    }
    
    class func sortLocations(by: String, locations: NSArray)->NSArray{
        var sortedArray = NSArray()
        if by == "Name" {
            sortedArray = locations.sorted { ($0 as! Location).locationName! < ($1 as! Location).locationName! } as NSArray
        }
        else if by == "Distance" {
            
            sortedArray = locations.sorted(by: { ($0 as! Location).distance(to: currentLocation) < ($1 as! Location).distance(to: currentLocation) }) as NSArray
        }
        return sortedArray
    }
    
}
