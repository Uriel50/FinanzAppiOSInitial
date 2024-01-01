//
//  CardView.swift
//  FinanzApp
//
//  Created by Uriel Candia on 12/10/23.
//

import UIKit

class CardView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCardView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCardView()
    }
    
    private func setupCardView() {
        if let backgroundColor = UIColor(named: "backgroundCard") {
            self.backgroundColor = backgroundColor
        } else {
            self.backgroundColor = .white // Un color predeterminado en caso de que no se encuentre el color en Assets
        }
        layer.cornerRadius = 12.5 // Radio de las esquinas
        layer.masksToBounds = false // Para permitir sombras
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 3.0 // Ajusta la sombra según tus necesidades
        translatesAutoresizingMaskIntoConstraints = false
    }
}
