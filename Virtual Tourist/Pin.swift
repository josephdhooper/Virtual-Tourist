//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Joseph Hooper on 4/14/16.
//  Copyright © 2016 josephdhooper. All rights reserved.
//  Code from https://github.com/jarrodparkes/virtual-tourist.git and https://github.com/udacity/ios-persistence-2.0

import CoreData
import MapKit

class Pin : NSManagedObject {
    @NSManaged var latitude : Double
    @NSManaged var longitude : Double
    @NSManaged var photos: [Photo]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(longitude: Double, latitude : Double, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func getCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
