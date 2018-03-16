//
//  Plant+CoreDataClass.swift
//  
//
//  Created by Yeontae Kim on 3/16/18.
//
//

import Foundation
import CoreData
import MapKit

@objc(Plant)
public class Plant: NSManagedObject {

    func getPinAnnotationsFromPin(plant: Plant) -> PinAnnotation {
        
        let pinAnnotation = PinAnnotation(plant: plant)
        
        pinAnnotation.title = plant.scientificName
        pinAnnotation.subtitle = plant.commonName
        
        return pinAnnotation
    }
    
}
