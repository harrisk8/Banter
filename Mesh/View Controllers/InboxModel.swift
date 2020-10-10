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
    
}

public struct InboxArray {
    
    static var inboxArrayNew: [InboxCellData] = []
    
    
}



