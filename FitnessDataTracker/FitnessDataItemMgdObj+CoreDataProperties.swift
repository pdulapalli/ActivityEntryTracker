//
//  FitnessDataItemMgdObj+CoreDataProperties.swift
//  FitnessDataTracker
//
//  Created by Anurag Dulapalli on 12/1/17.
//  Copyright © 2017 Anurag Dulapalli. All rights reserved.
//
//

import Foundation
import CoreData


extension FitnessDataItemMgdObj {
    @NSManaged public var username: String?
    @NSManaged public var activityType: String?
    @NSManaged public var comments: String?
    @NSManaged public var durationMinutes: Int64
    @NSManaged public var entryDate: Date?
    @NSManaged public var intensity: Float
}
