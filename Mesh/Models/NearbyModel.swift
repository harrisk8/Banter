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
    
}


struct NearbyArray {
    
    static var nearbyArray: [NearbyCellData] = []
    
}

struct formattedPosts {
    
    static var formattedPostsArray: [NearbyCellData] = []
}
