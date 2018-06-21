//
//  Location.swift
//  PhotoLocation
//
//  Copyright © 2018 divya. All rights reserved.
//

import Foundation
import MapKit

 class Location : NSObject, MKAnnotation {
    
    let title: String?
    let locationName: String?

    let coordinate: CLLocationCoordinate2D
    var notes : String
    var locationsArrayObj : NSMutableArray
    
    var locationLatitude: CLLocationDegrees
    var locationLongitude: CLLocationDegrees
    
    var isEditable : Bool
    
    var location: CLLocation {
        return CLLocation(latitude: self.locationLatitude, longitude: self.locationLongitude)
    }
    
    func distance(to location: CLLocation) -> CLLocationDistance {
        return location.distance(from: self.location)
    }
    
    init(title: String, locationName: String,  coordinate: CLLocationCoordinate2D, notes : String, isEditable: Bool) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        self.notes = notes
        self.locationLatitude = coordinate.latitude
        self.locationLongitude = coordinate.longitude
        self.locationsArrayObj = []
        self.isEditable = isEditable
        super.init()
    }
    

}
