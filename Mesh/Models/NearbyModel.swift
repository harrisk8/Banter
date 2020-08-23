//
//  NearbyModel.swift
//  Mesh
//
//  Created by Harris Kapoor on 8/22/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import Foundation

struct NearbyCellData {
    
    var author: String?
    var message: String?
    var score: Int?
    var timestamp: Double?
    
}

struct NearbyArray {
    
    static var nearbyArray: [NearbyCellData] = []
    
}
