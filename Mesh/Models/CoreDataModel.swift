//
//  CoreDataModel.swift
//  Mesh
//
//  Created by Harris Kapoor on 10/8/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import Foundation

public struct CoreDataCellData {
    
    var author: String?
    var message: String?
    var score: Int32?
    var timestamp: Double?
    var comments: [[String: AnyObject]]?
    var documentID: String?
    var postUUID: UUID?
    
}
