//
//  OptionCellMovements.swift
//  FinanzApp
//
//  Created by Uriel Candia on 09/12/23.
//

import UIKit

class OptionCellMovements: UICollectionViewCell {

    @IBOutlet weak var labelCell: UILabel!
    
   override var isSelected : Bool{
        didSet{
            highlightTitle(isSelected ? .white : .black)
            colorBackground(isSelected ? UIColor(named: "SelectedTab")! : UIColor(named: "UnselectedTab")!)
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func highlightTitle(_ color : UIColor){
        labelCell.textColor = color
    }
    func colorBackground (_ color :UIColor){
        labelCell.backgroundColor = color
    }
    
    func configCell(option:String){
        labelCell.text = option
        labelCell.layer.cornerRadius = labelCell.frame.height / 2.5
        labelCell.layer.masksToBounds = true
    }

}
