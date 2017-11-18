//
//  HomeViewController.swift
//  FourSquareDemo
//
//  Created by Saqib Omer on 13/11/2017.
//  Copyright © 2017 KaboomLab. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

class HomeViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    // Properties
    let locManager      = CLLocationManager()
    var currentLocation :CLLocationCoordinate2D!
    var venues : NSArray?
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locManager.requestWhenInUseAuthorization()
        
    }

    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
 
    }
    
    // MARK: - Actions
    
    @IBAction func showMap(_ sender: UIButton) {
        
        let venueObject = self.venues?.object(at: sender.tag) as! NSDictionary
   
        let locationObject = venueObject.object(forKey: "location") as! NSDictionary
        let lat = locationObject.object(forKey: "lat") as! Double
        let lng = locationObject.object(forKey: "lng") as! Double
        let name = venueObject.object(forKey: "name") as! String
        let mapView = self.storyboard?.instantiateViewController(withIdentifier: "mapView") as! MapViewController
        mapView.destinationLat   = lat
        mapView.destinationLng   = lng
        mapView.destinationTitle = name
        self.show(mapView, sender: self)
       
        
    }
    
    // MARK: - Delegates
    
    // MARK: - Location manager delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.searchResturants()
        currentLocation = locations.last?.coordinate
        locManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.startUpdatingLocation()
            currentLocation = manager.location?.coordinate
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.showAlert(title: "Error", msg: error.localizedDescription)
    }
    
    // MARK: - TableView methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let ven = self.venues {
            return ven.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! HomeTableViewCell
        let venueObject = self.venues?.object(at: indexPath.row) as! NSDictionary
        let name = venueObject.object(forKey: "name") as! String
        let locationObject = venueObject.object(forKey: "location") as! NSDictionary
        let distance = locationObject.object(forKey: "distance") as! NSNumber
        cell.nameLabel.text = name
        cell.distanceLabel.text = "\(distance) meters"
        cell.mapButton.tag = indexPath.row
        cell.mapButton.layer.cornerRadius = cell.mapButton.layer.frame.width / 2
        cell.mapButton.clipsToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    // MARK: - Helper Methods
    
    func setViews () {
        // Location Manager Init
        locManager.delegate = self;
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        self.getUserLocation();
        if CLLocationManager.locationServicesEnabled() {
            locManager.requestLocation();
        }
        // TableView Setup
        self.homeTableView.dataSource = self
        self.homeTableView.delegate   = self
        
        self.loadingView.layer.cornerRadius = 10.0
        self.loadingView.clipsToBounds      = true
    }
    
    func getUserLocation() {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .authorizedWhenInUse:
                locManager.startUpdatingLocation()
                
            default:
                showAlert(title: "Error", msg: "Unable to get lcoation")
            }
        } else {
            showAlert(title: "Error", msg: "Unable to get lcoation")
        }
    }
    
    func searchResturants() {
        self.loadingView.isHidden = false
        self.activityIndicator.startAnimating()
        let fourSquareApi = Api()
        let url = "https://api.foursquare.com/v2/venues/search?ll=\(currentLocation.latitude),\(currentLocation.longitude)&v=20160607&intent=resturant&limit=10&client_id=\(fourSquareApi.clientId)&client_secret=\(fourSquareApi.clientSecret)"
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        Alamofire.request(url, headers: headers)
            .responseJSON { response in
                
                if let status = response.response?.statusCode {
                    switch(status){
                    case 200:
                        DispatchQueue.main.async {
                            
                            if let result = response.result.value {
                                let JSON = result as! NSDictionary
                                let resp = JSON.value(forKey: "response") as! NSDictionary
                                let vens = resp.value(forKey: "venues") as! NSArray
                                
                                
                                self.venues = vens
                                self.loadingView.isHidden = true
                                self.activityIndicator.stopAnimating()
                                self.homeTableView.isHidden = false
                                self.homeTableView.reloadData()
                            }
                            
                            
                        }
                    default:
                        self.showAlert(title: "Error: \(status)", msg: "Error getting results")
                    }
                }
                
        }
    }
    
    
    func showAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
 

}
