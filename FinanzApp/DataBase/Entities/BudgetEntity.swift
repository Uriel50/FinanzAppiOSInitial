//
//  BudgetEntity.swift
//  FinanzApp
//
//  Created by Uriel Candia on 13/12/23.
//

import CoreData

@objc(BudgetEntity)
class BudgetEntity: NSManagedObject {
    @NSManaged var budgetId: Int64
    @NSManaged var nameBudget: String
    @NSManaged var userEmailBudget: String
    @NSManaged var userId: Int64
    
    // Relación con UserEntity
    @NSManaged var user: UserEntity
    
    // Relaciones inversas
    @NSManaged var incomes: Set<IncomeEntity>
    @NSManaged var expenses: Set<ExpenseEntity>
    @NSManaged var totals: Set<TotalsEntity>
}

extension BudgetEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BudgetEntity> {
        return NSFetchRequest<BudgetEntity>(entityName: "BudgetEntity")
    }
}
