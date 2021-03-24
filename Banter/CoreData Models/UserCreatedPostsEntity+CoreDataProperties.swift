//
//  UserCreatedPostsEntity+CoreDataProperties.swift
//  Mesh
//
//  Created by Harris Kapoor on 2/15/21.
//  Copyright © 2021 Avidi Technologies. All rights reserved.
//
//

import Foundation
import CoreData


extension UserCreatedPostsEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserCreatedPostsEntity> {
        return NSFetchRequest<UserCreatedPostsEntity>(entityName: "UserCreatedPostsEntity")
    }

    @NSManaged public var author: String?
    @NSManaged public var comments: NSObject?
    @NSManaged public var documentID: String?
    @NSManaged public var message: String?
    @NSManaged public var score: Int32
    @NSManaged public var timestamp: Double
    @NSManaged public var userDocID: String?

}
