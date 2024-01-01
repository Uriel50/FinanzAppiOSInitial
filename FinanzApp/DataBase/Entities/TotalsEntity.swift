//
//  TotalsEntity.swift
//  FinanzApp
//
//  Created by Uriel Candia on 13/12/23.
//

import CoreData

@objc(TotalsEntity)
class TotalsEntity: NSManagedObject {
    @NSManaged var idTotal: Int64
    @NSManaged var totalIncome: Double
    @NSManaged var totalExpense: Double
    @NSManaged var balanceTotal: Double
    @NSManaged var userEmailTotal: String
    @NSManaged var budgetId: Int64
    
    // Relación con BudgetEntity
    @NSManaged var budget: BudgetEntity
}

extension TotalsEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TotalsEntity> {
        return NSFetchRequest<TotalsEntity>(entityName: "TotalsEntity")
    }
}
