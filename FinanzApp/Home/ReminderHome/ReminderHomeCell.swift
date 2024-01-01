//
//  ReminderHomeCell.swift
//  FinanzApp
//
//  Created by Uriel Candia on 15/12/23.
//

import UIKit

class ReminderHomeCell: UITableViewCell {
    
    
    @IBOutlet weak var imageReminderHome: UIImageView!
    @IBOutlet weak var nameReminderHome: UILabel!
    @IBOutlet weak var categoryReminderHome: UILabel!
    @IBOutlet weak var dateReminderHome: UILabel!
    @IBOutlet weak var mountReminderHome: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with reminder: ReminderEntity){
        nameReminderHome.text = reminder.reminderTitle
        dateReminderHome.text = reminder.reminderDate
        categoryReminderHome.text = reminder.reminderCategory
        mountReminderHome.text = String(format: "%.2f", reminder.reminderMount)
    }


}
