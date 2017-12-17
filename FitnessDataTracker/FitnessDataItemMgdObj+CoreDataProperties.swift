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

//    @nonobjc public class func fetchRequest() -> NSFetchRequest<FitnessDataItemMgdObj> {
//        return NSFetchRequest<FitnessDataItemMgdObj>(entityName: "FitnessDataItem")
//    }
    
    @NSManaged public var username: String?
    @NSManaged public var activityType: String?
    @NSManaged public var comments: String?
    @NSManaged public var durationMinutes: Double
    @NSManaged public var entryDate: NSDate?
    @NSManaged public var intensity: Float

}
