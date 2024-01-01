//
//  OptionCell.swift
//  FinanzApp
//
//  Created by Uriel Candia on 07/12/23.
//

import UIKit

class OptionCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    override var isSelected: Bool{
        didSet{
            highlightTitle(isSelected ? .white : .black)
            colorBackground(isSelected ? UIColor(named: "SelectedTab")! : UIColor(named: "UnselectedTab")!)
        }
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func highlightTitle(_ color : UIColor){
        titleLabel.textColor = color
    }
    func colorBackground (_ color :UIColor){
        titleLabel.backgroundColor = color
    }
    
    func configCell(option:String){
        titleLabel.text = option
        titleLabel.layer.cornerRadius = titleLabel.frame.height / 2.5
        titleLabel.layer.masksToBounds = true
    }
    
}
