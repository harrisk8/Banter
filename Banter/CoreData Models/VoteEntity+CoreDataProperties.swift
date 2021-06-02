//
//  VoteEntity+CoreDataProperties.swift
//  Banter
//
//  Created by Harris Kapoor on 5/31/21.
//  Copyright © 2021 Avidi Industries Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension VoteEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VoteEntity> {
        return NSFetchRequest<VoteEntity>(entityName: "VoteEntity")
    }

    @NSManaged public var documentID: String?
    @NSManaged public var userDislikedPost: Bool
    @NSManaged public var userLikedPost: Bool

}

extension VoteEntity : Identifiable {

}
