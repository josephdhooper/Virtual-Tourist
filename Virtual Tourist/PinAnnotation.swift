//
//  MapPin.swift
//  Virtual Tourist
//
//  Created by Joseph Hooper on 4/14/16.
//  Copyright © 2016 josephdhooper. All rights reserved.
//  Code from https://github.com/jarrodparkes/virtual-tourist.git and https://github.com/udacity/ios-persistence-2.0

import MapKit

class PinAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var pin : Pin?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    init(pin : Pin) {
        self.pin = pin
        self.coordinate = pin.getCoordinate()
    }
    
    func updateCoordinate(newCoordinate: CLLocationCoordinate2D)->Void {
        willChangeValueForKey("coordinate")
        coordinate = newCoordinate
        didChangeValueForKey("coordinate")
    }
}