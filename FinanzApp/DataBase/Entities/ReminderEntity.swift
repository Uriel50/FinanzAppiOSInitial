//
//  ReminderEntity.swift
//  FinanzApp
//
//  Created by Uriel Candia on 13/12/23.
//

import CoreData

@objc(ReminderEntity)
class ReminderEntity: NSManagedObject {
    @NSManaged var reminderId: Int64
    @NSManaged var reminderTitle: String
    @NSManaged var reminderCategory: String
    @NSManaged var reminderDate: String
    @NSManaged var hour: String
    @NSManaged var reminderMount: Double
    @NSManaged var userEmailReminder: String
    @NSManaged var userId: Int64
    
    // Relación con UserEntity
    @NSManaged var user: UserEntity
}

extension ReminderEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReminderEntity> {
        return NSFetchRequest<ReminderEntity>(entityName: "ReminderEntity")
    }
}

