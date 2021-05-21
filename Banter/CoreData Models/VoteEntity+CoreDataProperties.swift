//
//  VoteEntity+CoreDataProperties.swift
//  Banter
//
//  Created by Harris Kapoor on 5/20/21.
//  Copyright © 2021 Avidi Industries Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension VoteEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VoteEntity> {
        return NSFetchRequest<VoteEntity>(entityName: "VoteEntity")
    }

    @NSManaged public var userLikedPost: Bool
    @NSManaged public var userDislikedPost: Bool
    @NSManaged public var documentID: String?

}

extension VoteEntity : Identifiable {

}
