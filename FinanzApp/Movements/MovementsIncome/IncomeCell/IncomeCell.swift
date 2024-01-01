//
//  IncomeCell.swift
//  FinanzApp
//
//  Created by Uriel Candia on 16/12/23.
//

import UIKit

class IncomeCell: UITableViewCell {

    @IBOutlet weak var nameIncome: UILabel!
    @IBOutlet weak var categoryIncome: UILabel!
    @IBOutlet weak var dateIncome: UILabel!
    @IBOutlet weak var mountIncome: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with income: IncomeEntity){
        nameIncome.text = income.incomeName
        categoryIncome.text = income.incomeCategory
        dateIncome.text = income.incomeDate
        mountIncome.text = "+$"+String(format: "%.2f", income.incomeMount)
    }

}
