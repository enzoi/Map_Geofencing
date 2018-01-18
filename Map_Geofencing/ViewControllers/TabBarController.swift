//
//  TabBarController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 12/21/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import CoreLocation

class TabBarController: UITabBarController {

    var photoStore: PhotoStore!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        for item in self.tabBar.items! {
            if let image = item.image {
                item.image = image.withRenderingMode(.alwaysOriginal)
            }
        }
    }

}
