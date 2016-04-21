//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Joseph Hooper on 4/14/16.
//  Copyright © 2016 josephdhooper. All rights reserved.
//  Code from https://github.com/jarrodparkes/virtual-tourist.git and https://github.com/udacity/ios-persistence-2.0

import CoreData
import UIKit

class Photo : NSManagedObject {
    
    @NSManaged var id: String
    @NSManaged var imageUrl: String
    @NSManaged var localPath: String
    @NSManaged var pin: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        id = dictionary[Keys.ID] as! String
        imageUrl = dictionary[Keys.Url] as! String
        localPath = pathForIdentifier(id)
    }

    var photoImage: UIImage? {
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(id)
        }
        
        set {
            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: id)
        
        }
    }
    
    static func photosFromResult(result: AnyObject, context: NSManagedObjectContext) -> [Photo]{
        var photos = [Photo]()
        
        if let photosResult = result["photos"] as? NSDictionary {
            if let photosArray = photosResult["photo"] as? [[String: AnyObject]] {
                for dict in photosArray {
                    let photo = Photo(dictionary: dict, context: context)
                    photos.append(photo)
                }
            }
        }
        return photos
    }
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }
    
// Code repurposed from https://github.com/yxiong/udacity-ios-developer-workout-log. 
    
    override func prepareForDeletion() {
            let fileManager = NSFileManager()
            do {
                try fileManager.removeItemAtPath(localPath)
            } catch  {
        }
        
        }
    }


