//
//  ImageCache.swift
//  Virtual Tourist
//
//  Created by Joseph Hooper on 4/14/16.
//  Copyright © 2016 josephdhooper. All rights reserved.
//  Code from https://github.com/jarrodparkes/virtual-tourist.git . 
import UIKit

class ImageCache {
    
    // Code for ImageCache was repurposed from "Favorite Actors" app, created by Jason Schatz and distributed by Udacity.
    
    private var inMemoryCache = NSCache()

    func imageWithIdentifier(identifier: String?) -> UIImage? {

        if identifier == nil || identifier! == "" {
            return nil
}

let path = pathForIdentifier(identifier!)

        if let image = inMemoryCache.objectForKey(path) as? UIImage {
            return image
        }
        
        // Next Try the hard drive
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }
        
        return nil
}

    func storeImage(image: UIImage?, withIdentifier identifier: String) {
        print("Caching photo")
        let path = pathForIdentifier(identifier)
        
        // If the image is nil, remove images from the cache
        if image == nil {
            inMemoryCache.removeObjectForKey(path)
            
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            } catch _ {}
            
            return
        }
        
        // Otherwise, keep the image in memory
        inMemoryCache.setObject(image!, forKey: path)
        
        // And in documents directory
        let data = UIImagePNGRepresentation(image!)!
        data.writeToFile(path, atomically: true)
    }
    
    // MARK: - Helper
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }
}

    
//    func imageWithPath(path: String) -> UIImage? {
//            if let image = inMemoryCache.objectForKey(path) as? UIImage {
//            return image
//        }
//        
//        if let data = NSData(contentsOfFile: path) {
//            return UIImage(data: data)
//        }
//        
//        return nil
//    }
//    
//    func storeImage(image: UIImage?, withPath path: String) {
//        if image == nil {
//            inMemoryCache.removeObjectForKey(path)
//            
//            do {
//                try NSFileManager.defaultManager().removeItemAtPath(path)
//            } catch _ {}
//            
//            return
//        }
//        
//        inMemoryCache.setObject(image!, forKey: path)
//        
//        let data = UIImagePNGRepresentation(image!)!
//        data.writeToFile(path, atomically: true)
//    }
//}