//
//  NotificationEntity+CoreDataProperties.swift
//  Mesh
//
//  Created by Harris Kapoor on 2/25/21.
//  Copyright © 2021 Avidi Technologies. All rights reserved.
//
//

import Foundation
import CoreData


extension NotificationEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotificationEntity> {
        return NSFetchRequest<NotificationEntity>(entityName: "NotificationEntity")
    }

    @NSManaged public var message: String?
    @NSManaged public var documentID: String?
    @NSManaged public var notificationTimestamp: Double
    @NSManaged public var opened: Bool
    @NSManaged public var author: String?

}
