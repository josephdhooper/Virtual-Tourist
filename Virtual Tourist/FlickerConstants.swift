//
//  FlickerConstants.swift
//  Virtual Tourist
//
//  Created by Joseph Hooper on 4/16/16.
//  Copyright © 2016 josephdhooper. All rights reserved.
//  Code from https://github.com/jarrodparkes/virtual-tourist.git and other Udacity-focused repositories was repurposed for this project.

import Foundation

extension FlickrClient {
    struct Constants {
        static let BASE_URL = "https://api.flickr.com/services/rest/"
        static let METHOD_NAME = "flickr.photos.search"
        static let API_KEY = "0b83911536bb223e4a0eb9cc422cd6cd"
        static let EXTRAS = "url_m"
        static let SAFE_SEARCH = "1"
        static let DATA_FORMAT = "json"
        static let NO_JSON_CALLBACK = "1"
        
    }
    
    struct Parameters {
        static let BOUNDING_BOX_HALF_WIDTH = 0.1
        static let BOUNDING_BOX_HALF_HEIGHT = 0.1
        static let LAT_MIN = -90.0
        static let LAT_MAX = 90.0
        static let LON_MIN = -180.0
        static let LON_MAX = 180.0
        static let MAX_PAGE = 200
        static let PER_PAGE = 20
        
    }
    
    
}