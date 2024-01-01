//
//  ReminderTableViewCell.swift
//  FinanzApp
//
//  Created by Uriel Candia on 14/12/23.
//

import UIKit

class ReminderCell: UITableViewCell {

    @IBOutlet weak var reminderTitleLabel: UILabel!
    @IBOutlet weak var reminderDateLabel: UILabel!
    @IBOutlet weak var reminderCategoryLabel: UILabel!
    @IBOutlet weak var reminderAmountLabel: UILabel!
    
    @IBOutlet weak var imageReminder: UIImageView!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with reminder: ReminderEntity) {
            reminderTitleLabel.text = reminder.reminderTitle
            reminderDateLabel.text = reminder.reminderDate
            reminderCategoryLabel.text = reminder.reminderCategory
            reminderAmountLabel.text = String(format: "%.2f", reminder.reminderMount)
            // Formatea y asigna cualquier otro dato que necesites mostrar.
        }

}
