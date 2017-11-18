//
//  MapViewController.swift
//  FourSquareDemo
//
//  Created by Saqib Omer on 13/11/2017.
//  Copyright © 2017 KaboomLab. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController , MKMapViewDelegate{

    // Properties
    @IBOutlet weak var locationMapView: MKMapView!
    
    var destinationLat : Double!
    var destinationLng : Double!
    var destinationTitle : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = destinationTitle
    }

    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
 
    }
    
    // MARK: - Actions
    
    
    // MARK: - Delegates
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.green
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    // MARK: - Helper Methods
    
    func setViews () {
        
        // Set Map View
        self.locationMapView.showsUserLocation = true
        self.locationMapView.delegate = self
        
        let sourceLocation = CLLocationCoordinate2D(latitude: locationMapView.userLocation.coordinate.latitude, longitude: locationMapView.userLocation.coordinate.longitude)
        let destinationLocation = CLLocationCoordinate2D(latitude: self.destinationLat, longitude: self.destinationLng)
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "Your Location"
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = self.destinationTitle
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        self.locationMapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        DispatchQueue.main.async {
            
            let directionRequest = MKDirectionsRequest()
            directionRequest.source = sourceMapItem
            directionRequest.destination = destinationMapItem
            directionRequest.transportType = .automobile
            let directions = MKDirections(request: directionRequest)
            
            directions.calculate {
                (response, error) -> Void in
                
                guard let response = response else {
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        let location : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: self.destinationLat, longitude: self.destinationLng)
                        let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                        
                        self.locationMapView.setRegion(region, animated: true)

                        
                        self.showAlert(title: "Error", msg: error.localizedDescription)
                    }
                    
                    return
                }
                
                let route = response.routes[0]
                self.locationMapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
                
                let rect = route.polyline.boundingMapRect
                self.locationMapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
                self.locationMapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
            }
        }
        
        
        
    
    }
    
    func showAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
 

}
