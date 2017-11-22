//
//  FitnessDataItem+CoreDataProperties.swift
//  FitnessDataTracker
//
//  Created by Anurag Dulapalli on 11/21/17.
//  Copyright © 2017 Anurag Dulapalli. All rights reserved.
//
//

import Foundation
import CoreData


extension FitnessDataItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FitnessDataItem> {
        return NSFetchRequest<FitnessDataItem>(entityName: "FitnessDataItem")
    }

    @NSManaged public var activityType: String?
    @NSManaged public var durationMinutes: Double
    @NSManaged public var comments: String?
    @NSManaged public var intensity: Int16
    @NSManaged public var entryDate: NSDate?

}
