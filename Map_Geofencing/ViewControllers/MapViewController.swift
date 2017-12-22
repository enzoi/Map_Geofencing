//
//  MapViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 10/31/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {
    
    var photoStore: PhotoStore!
    var locationManager = CLLocationManager()
    lazy var mapView = GMSMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get photoStore from TabBarController
        let tabBar = self.tabBarController as! TabBarController
        self.photoStore = tabBar.photoStore
        
        // Google Maps setting
        let camera = GMSCameraPosition.camera(withLatitude: 37.7669, longitude: -122.4716, zoom: 15.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        self.view = mapView
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 37.7669, longitude: -122.4716)
        marker.title = "Tree Name"
        marker.snippet = "common name"
        marker.map = mapView
        
        //Location Manager code to fetch current location
        setUpLocationManager()
        
        // Fetch all plant markers
        fetchAllPlantMarkers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.clear()
        fetchAllPlantMarkers()
    }
    
    func setUpLocationManager() {
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
    }
    
    // Fetch all saved pins with annotation
    
    func fetchAllPlantMarkers() {
        
        var fetchedPlants = [Plant]()
        
        photoStore.fetchAllPins() { (plantsResult) in
            
            switch plantsResult {
                
            case let .success(plants):
                
                fetchedPlants = plants
                
                if fetchedPlants.count > 0 {

                    for plant in fetchedPlants {
                        
                        let plantMarker = GMSMarker()
                        plantMarker.position = CLLocationCoordinate2D(latitude: plant.latitude, longitude: plant.longitude)
                        plantMarker.title = plant.scientificName
                        plantMarker.snippet = plant.commonName
                        plantMarker.map = self.mapView

                    }
                    
                } else {
                    print("Nothing to fetch")
                }
                
            case .failure(_):
                fetchedPlants = []
            }
        }
        
    }
    
}

// MARK: - CLLocation Manager Delegate

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        let _ = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        
//        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude,
//                                              longitude: userLocation!.coordinate.longitude, zoom: 13.0)
//         mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)

        mapView.isMyLocationEnabled = true
        self.view = mapView
        
        locationManager.stopUpdatingLocation()
    }
    
    func centerMapOnLocation(location: CLLocation) {
        
    }
}
