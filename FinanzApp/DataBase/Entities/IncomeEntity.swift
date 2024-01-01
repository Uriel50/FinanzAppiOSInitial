//
//  IncomeEntity.swift
//  FinanzApp
//
//  Created by Uriel Candia on 13/12/23.
//

import CoreData

@objc(IncomeEntity)
class IncomeEntity: NSManagedObject {
    @NSManaged var idIncome: Int64
    @NSManaged var incomeName: String
    @NSManaged var incomeMount: Double
    @NSManaged var incomeCategory: String
    @NSManaged var incomeDate: String
    @NSManaged var userEmailIncome: String
    @NSManaged var budgetId: Int64
    // Relación con BudgetEntity
    @NSManaged var budget: BudgetEntity
}

extension IncomeEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<IncomeEntity> {
        return NSFetchRequest<IncomeEntity>(entityName: "IncomeEntity")
    }
}
