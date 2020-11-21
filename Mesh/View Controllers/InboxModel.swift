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


public struct InboxCellData {
    
    var author: String?
    var message: String?
    var score: Int32?
    var timestamp: Double?
    var comments: [[String: AnyObject]]?
    var documentID: String?
    var lastCommentTimestamp: Double?
    var notifications: [[String: AnyObject]]?
    var userDocID: String?
    
}


public struct InboxArray {
    
    static var inboxArrayNew: [InboxCellData] = []
    
    
}

public struct NotificationData {
    var author: String?
    var message: String?
    var documentID: String?
    var opened: Bool?
}

public struct NotificationArrayData {
    
    static var notificationArray: [NotificationData]?
    
    static var testInboxArray: [[String: AnyObject]] = []
}




