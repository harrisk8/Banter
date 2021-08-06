//
//  ApplicationResources.swift
//  Banter
//
//  Created by Harris Kapoor on 8/2/21.
//  Copyright © 2021 Avidi Industries Inc. All rights reserved.
//

import Foundation

enum newOrExistingUser {
    case newUser
    case existingUser
}

enum userAddedSchool {
    case userHasAddedSchool
    case userHasNotAddedSchool
}

enum pathwayIntoComments {
    case nearbyToComments
    case trendingToComments
    case inboxToComments
    case mySchoolToComments
}

enum votePathway {
    case voteFromNearby
    case voteFromTrending
    case voteFromMySchool
}

enum postingTo {
    case postToNearby
    case postToSchool
}

struct CollegeData: Codable {
    var LocationName: String
}

struct MySchoolCellData {
    
    var author: String?
    var message: String?
    var score: Int32?
    var timestamp: Double?
    var comments: [[String: AnyObject]]?
    var documentID: String?
    var userDocID: String?
    var schoolName: String?
    var likedPost: Bool?
    var dislikedPost: Bool?
    
}

struct MySchoolPosts {
    
    static var MySchoolPostsArray: [MySchoolCellData] = []
    
}
