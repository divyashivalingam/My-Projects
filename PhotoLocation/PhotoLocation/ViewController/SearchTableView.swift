//
//  SearchTableView.swift
//  PhotoLocation
//
//  Copyright © 2018 divya. All rights reserved.
//

import UIKit
import MapKit

class SearchTableView : UITableViewController {
    var locationMapView: MKMapView? = nil
    var searchedLocations:[MKMapItem] = []
    var locationMapViewDelegate:LocationMapViewDelegate? = nil
}


extension SearchTableView : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let locationMapView = locationMapView,
            let searchBarText = searchController.searchBar.text else { return }
        let searchRequest = MKLocalSearchRequest()
        searchRequest.region = locationMapView.region
        searchRequest.naturalLanguageQuery = searchBarText
        
        let localSearch = MKLocalSearch(request: searchRequest)
        localSearch.start { response, _ in
            guard let searchResponse = response else {
                return
            }
            self.searchedLocations = searchResponse.mapItems
            self.tableView.reloadData()
        }
    }
}

extension SearchTableView {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedLocations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell")!
        let placeMark = searchedLocations[indexPath.row].placemark
        cell.textLabel?.text = placeMark.name
        cell.detailTextLabel?.text = placeMark.locality
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = searchedLocations[indexPath.row].placemark
        self.presentAddAlert(placeMark: selectedItem)
    }
    
    func presentAddAlert(placeMark: MKPlacemark){
        let addAlert = UIAlertController(title: "Do you want to add this location", message: "Enter name for your location", preferredStyle: .alert)
        
        addAlert.addTextField { (textField) in
            textField.text = ""
            textField.autocapitalizationType = .words
        }
        
        addAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak addAlert] (_) in
            let textField = addAlert?.textFields![0]
            if ((textField?.text? .isEmpty)!){
                self.presentAddAlert(placeMark: placeMark)
            }
            else{
                self.locationMapViewDelegate?.addAnnotationForLocation(locationPlacemark: placeMark, locationName: (textField?.text)!)
                self.dismiss(animated: true, completion: nil)
            }
            
        }))
        
        addAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel))
        self.present(addAlert, animated: true, completion: nil)
    }
    
    
}

