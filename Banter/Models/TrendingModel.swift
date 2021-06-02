//
//  TrendingModel.swift
//  Mesh
//
//  Created by Harris Kapoor on 10/4/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import Foundation

public struct TrendingCellData {
    
    var author: String?
    var message: String?
    var score: Int32?
    var timestamp: Double?
    var comments: [[String: AnyObject]]?
    var documentID: String?
    var postLocationCity: String?
    var postLocationState: String?
    var likedPost: Bool?
    var dislikedPost: Bool?
    
}


struct formattedTrendingPosts {
    
    static var formattedTrendingPostsArray: [TrendingCellData] = []
}
