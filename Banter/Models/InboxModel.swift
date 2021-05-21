//
//  InboxModel.swift
//  Mesh
//
//  Created by Harris Kapoor on 10/6/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import Foundation
import UIKit
import Firebase

//Struct for posts with new notifications fetched from database
public struct NotificationDataWholePost {
    
    var author: String?
    var message: String?
    var score: Int32?
    var timestamp: Double?
    var comments: [[String: AnyObject]]?
    var documentID: String?
    var lastCommentTimestamp: Double?
    var notifications: [[String: AnyObject]]?
    var userDocID: String?
    var locationCity: String?
    var locationState: String?
    
}

//Array to hold above-declared struct
public struct NotificationWholePostArray {
    
    static var notificationWholePostArray: [NotificationDataWholePost] = []
    
}


//Struct to hold notifications extracted from above-declared posts
public struct NotificationDataFormatted {
    
    var author: String?
    var message: String?
    var documentID: String?
    var opened: Bool?
    var notificationTimestamp: Double?
    
}


//Array to hold array of notifications, feeds Inbox tableview
public struct NotificationArrayData {
    
    static var notificationArrayUnsorted: [[String: AnyObject]] = []
    
    static var notificationArraySorted: [NotificationDataFormatted] = []
    
    static var oldNotificationsFromCoreData: [NotificationDataFormatted] = []
    
    static var notificationArrayFinal: [NotificationDataFormatted] = []
}




