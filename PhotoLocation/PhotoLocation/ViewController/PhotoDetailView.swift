//
//  PhotoDetailView.swift
//  PhotoLocation
//
//  Copyright © 2018 divya. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class PhotoDetailView : UIViewController{
    
    @IBOutlet weak var photodetaillabel: UILabel!
    @IBOutlet weak var photoNotes: UITextView!
    @IBOutlet weak var detailMapView: MKMapView!
    let theRegionRadius : CLLocationDistance = 11000

    var locationDetail : Location?
    var locationMapViewDelegate:LocationMapViewDelegate? = nil

    override func viewDidLoad() {
        photodetaillabel.text = locationDetail?.locationName
        photoNotes.delegate = self
        detailMapView.delegate = self

        self.title = "Details"

        if (locationDetail?.notes .isEmpty)! {
            photoNotes.text = "Add Notes here"
            photoNotes.textColor = UIColor.lightGray
        }
        else{
            photoNotes.text = locationDetail?.notes
            photoNotes.textColor = UIColor.black
        }

        if !((locationDetail?.isEditable)!){
            photoNotes.isUserInteractionEnabled = false
        }
        else{
            let saveNotesButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
            self.navigationItem.rightBarButtonItems = [saveNotesButton]
        }
        
        self.addLocation();

    }
    
    @objc func saveTapped(){
        let fetchedLocation = LocationManager.fetchLocationBy(queryStr: (locationDetail?.locationName)!)
        
        if photoNotes.textColor != UIColor.lightGray{
            for location in fetchedLocation as! [NSManagedObject] {
                location.setValue(self.photoNotes.text, forKey: "notes")
                if LocationManager.saveLocation(){
                    print("Notes updated")
                    self.showSaveSuccessAlert()
                }
            }
        }
    }
    
    func showSaveSuccessAlert(){
        let saveAlert = UIAlertController(title: "Notes saved", message: "Thank You", preferredStyle: .alert)
        saveAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(saveAlert, animated: true, completion: nil)
    }
    
    func addLocation() {
        
        let locationCoordinate = MKCoordinateRegionMakeWithDistance((locationDetail?.coordinate)!, theRegionRadius, theRegionRadius)
        detailMapView.setRegion(locationCoordinate, animated: true)
        
        detailMapView.addAnnotation(locationDetail!)

    }
}

extension PhotoDetailView : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotationA = annotation as? Location else {return nil}
        let annotationIdentifier = "annotateID"
        
        var annotationView : MKAnnotationView
        
        if let dequedAnnotationView = detailMapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier){
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
}

extension PhotoDetailView : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        //mimicking placeholder
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("Printing notes \(textView.text)")
        
        if textView.text.isEmpty {
            textView.text = "Add Notes here"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
