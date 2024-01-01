//
//  ExpenseCell.swift
//  FinanzApp
//
//  Created by Uriel Candia on 16/12/23.
//

import UIKit

class ExpenseCell: UITableViewCell {

    @IBOutlet weak var nameExpense: UILabel!
    @IBOutlet weak var categoryExpense: UILabel!
    @IBOutlet weak var dateExpense: UILabel!
    @IBOutlet weak var mountExpense: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with expense: ExpenseEntity){
        nameExpense.text = expense.expenseName
        categoryExpense.text = expense.expenseCategory
        dateExpense.text = expense.expenseDate
        mountExpense.text = "-$"+String(format: "%.2f", expense.expenseMount)
    }
}
