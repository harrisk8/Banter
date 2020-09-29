//
//  NearbyPostsEntity+CoreDataProperties.swift
//  Mesh
//
//  Created by Harris Kapoor on 9/27/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//
//

import Foundation
import CoreData


extension NearbyPostsEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NearbyPostsEntity> {
        return NSFetchRequest<NearbyPostsEntity>(entityName: "NearbyPostsEntity")
    }

    @NSManaged public var author: String?
    @NSManaged public var message: String?
    @NSManaged public var score: Int32
    @NSManaged public var timestamp: Double
    @NSManaged public var documentID: String?
    @NSManaged public var comments: NSArray?

}
