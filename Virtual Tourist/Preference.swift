//
//  Preference.swift
//  Virtual Tourist
//
//  Created by Joseph Hooper on 4/14/16.
//  Copyright © 2016 josephdhooper. All rights reserved.
//  Code from https://github.com/jarrodparkes/virtual-tourist.git and other Udacity-focused repositories was repurposed for this project.

import CoreData
import MapKit

class Preference : NSManagedObject {
    @NSManaged var latitude : Double
    @NSManaged var longitude : Double
    @NSManaged var latitudeDelta : Double
    @NSManaged var longitudeDelta : Double
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(longitude: Double, latitude : Double, longitudeDelta: Double, latitudeDelta: Double, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Preference", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.latitude = latitude
        self.longitude = longitude
        self.latitudeDelta = latitudeDelta
        self.longitudeDelta = longitudeDelta
    }
    
    static func loadPreference()-> Preference? {
        var preference : Preference?
        do {
            let fetchRequest = NSFetchRequest(entityName: "Preference")
            fetchRequest.fetchLimit = 1
            if let results = try CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(fetchRequest) as? [Preference] {
                if (results.count > 0) {
                    preference = results[0]
                }
            }
        } catch {
        }
        return preference
    }
}
