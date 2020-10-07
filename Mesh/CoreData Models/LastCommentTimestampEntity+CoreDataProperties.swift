//
//  LastCommentTimestampEntity+CoreDataProperties.swift
//  Mesh
//
//  Created by Harris Kapoor on 10/5/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//
//

import Foundation
import CoreData


extension LastCommentTimestampEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LastCommentTimestampEntity> {
        return NSFetchRequest<LastCommentTimestampEntity>(entityName: "LastCommentTimestampEntity")
    }

    @NSManaged public var lastCommentTimestamp: Double

}
