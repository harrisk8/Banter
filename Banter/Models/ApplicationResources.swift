//
//  ApplicationResources.swift
//  Banter
//
//  Created by Harris Kapoor on 8/2/21.
//  Copyright © 2021 Avidi Industries Inc. All rights reserved.
//

import Foundation

enum newOrExistingUser {
    case newUser
    case existingUser
}

enum userAddedSchool {
    case userHasAddedSchool
    case userHasNotAddedSchool
}

struct CollegeData: Codable {
    var LocationName: String
}
