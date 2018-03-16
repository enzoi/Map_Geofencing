//
//  BottomSheetController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 3/15/18.
//  Copyright © 2018 YTK. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import MapKit
import FirebaseAuth

class BottomSheetController: UIViewController {
    
    let cellId = "cellId"
    var nearbyPlants : [Plant]!
    
    var photoStore: PhotoStore!
    var locationManager: CLLocationManager?
    var currentUserLocation: CLLocation?
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!

    
    let fullView: CGFloat = -35 // match top of search bar to bottom of nav bar
    var partialView: CGFloat {
        return UIScreen.main.bounds.height - 140 // header view + search bar + first cell height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.subviews.first!.layer.cornerRadius = 2.5
        headerView.subviews.first!.layer.masksToBounds = true
        
        // Sort plant array by distance from user location
        for plant in nearbyPlants {
            plant.distance = getDistance(plant: plant)
        }
        
        nearbyPlants = nearbyPlants.sorted(by: { $0.distance! < $1.distance! })
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "BottomSheetCell", bundle: nil), forCellReuseIdentifier: cellId)
        tableView.reloadData()
        
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(BottomSheetController.panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        prepareBackgroundView()
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Show top of the view for scrolling up
        UIView.animate(withDuration: 0.6, animations: { [weak self] in
            let frame = self?.view.frame
            let yComponent = self?.partialView
            self?.view.frame = CGRect(x: 0, y: yComponent!, width: frame!.width, height: frame!.height)
        })
    }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        
        let y = self.view.frame.minY

        if (y + translation.y >= fullView) && (y + translation.y <= partialView) {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if recognizer.state == .ended {
            var duration =  velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y )
            
            duration = duration > 1.3 ? 1 : duration
            
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if  velocity.y >= 0 {
                    self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: self.view.frame.height)
                } else {
                    self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: self.view.frame.height)
                }
                
            }, completion: { [weak self] _ in
                if ( velocity.y < 0 ) {
                    self?.tableView.isScrollEnabled = true
                }
            })
        }
    }
    
    
    func prepareBackgroundView() {
        
        let blurEffect = UIBlurEffect.init(style: .dark)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        view.insertSubview(bluredView, at: 0)
    }
    
}


// Mark: - TableView DataSource, Delegate Methods

extension BottomSheetController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return nearbyPlants.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! BottomSheetCell
        
        configure(cell: cell, for: indexPath)
        return cell
    }
}


// MARK: - Configure TableView Cell

extension BottomSheetController {
    
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        
        guard let cell = cell as? BottomSheetCell else {
            return
        }
        
        let plant: Plant
        plant = nearbyPlants[indexPath.row]
        
        cell.distance.text = plant.distance
        cell.scientificName.text = plant.scientificName
    }
    
    private func getDistance(plant: Plant) -> String {
        
        guard let userLocation = self.locationManager?.location else { return "N/A" }
        let plantLocation = CLLocation(latitude: plant.latitude, longitude: plant.longitude)
        
        let distanceInMeters = userLocation.distance(from: plantLocation) // result is in meters
        let distanceInMiles = distanceInMeters / 1609
        
        if (distanceInMiles <= 10) {
            // under 10 mile - 1.7 miles
            return String(format: "%.1f", distanceInMiles) + "miles"
        } else {
            // out of 10 mile - 12 miles
            return String(format: "%.0f", distanceInMiles) + "miles"
        }
    }
}

// Mark: - Gesture Recognizer Delegate

extension BottomSheetController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
        let direction = gesture.velocity(in: view).y
        
        let y = view.frame.minY
        if (y == fullView && tableView.contentOffset.y == 0 && direction > 0) || (y == partialView) {
            tableView.isScrollEnabled = false
        } else {
            tableView.isScrollEnabled = true
        }
        
        return false
    }
    
}

