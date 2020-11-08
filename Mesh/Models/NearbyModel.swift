//
//  NearbyModel.swift
//  Mesh
//
//  Created by Harris Kapoor on 8/22/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import Foundation

public struct NearbyCellData {
    
    var author: String?
    var message: String?
    var score: Int32?
    var timestamp: Double?
    var comments: [[String: AnyObject]]?
    var documentID: String?
    var loadedFromCoreData: Bool?
    var userDocID: String?
    
}

//Struct to contain new posts fetched from server at startup
struct newlyFetchedNearbyPosts {
    
    static var newlyFetchedNearbyPostsArray: [NearbyCellData] = []
    
}

//Struct to contain array that merges old Core Data posts and new posts
struct nearbyPostsFinal {
    
    static var finalNearbyPostsArray: [NearbyCellData] = []
}
