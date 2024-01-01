//
//  UsertEntity.swift
//  FinanzApp
//
//  Created by Uriel Candia on 13/12/23.
//

import CoreData

@objc(UserEntity)
class UserEntity: NSManagedObject {
    @NSManaged var userId: Int64
    @NSManaged var userNickname: String
    @NSManaged var userName: String
    @NSManaged var userLastName: String
    @NSManaged var userSex: String
    @NSManaged var userEmail: String
    @NSManaged var userKey: String
    
    // Relaciones
    @NSManaged var budgets: Set<BudgetEntity>
    @NSManaged var reminders: Set<ReminderEntity>
    
    // Métodos para agregar o eliminar budgets
    func addBudget(budget: BudgetEntity) {
        self.budgets.insert(budget)
    }
    
    func removeBudget(budget: BudgetEntity) {
        self.budgets.remove(budget)
    }
    
    // Métodos para agregar o eliminar reminders
    func addReminder(reminder: ReminderEntity) {
        self.reminders.insert(reminder)
    }
    
    func removeReminder(reminder: ReminderEntity) {
        self.reminders.remove(reminder)
    }
    
}

extension UserEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }
}


