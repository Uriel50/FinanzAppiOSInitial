//
//  ExpenseEntity.swift
//  FinanzApp
//
//  Created by Uriel Candia on 13/12/23.
//

import CoreData

@objc(ExpenseEntity)
class ExpenseEntity: NSManagedObject {
    @NSManaged var idExpense: Int64
    @NSManaged var expenseName: String
    @NSManaged var expenseMount: Double
    @NSManaged var expenseCategory: String
    @NSManaged var expenseDate: String
    @NSManaged var userEmailExpense: String
    @NSManaged var budgetId: Int64
    
    // Relación con BudgetEntity
    @NSManaged var budget: BudgetEntity
}

extension ExpenseEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExpenseEntity> {
        return NSFetchRequest<ExpenseEntity>(entityName: "ExpenseEntity")
    }
}
