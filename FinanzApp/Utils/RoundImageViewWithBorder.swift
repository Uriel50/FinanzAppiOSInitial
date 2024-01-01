//
//  RoundImageViewWithBorder.swift
//  FinanzApp
//
//  Created by Uriel Candia on 04/12/23.
//

import UIKit

class RoundImageViewWithBorder: UIImageView {
    
    // Ajusta el ancho del borde según tus necesidades
    let borderWidth: CGFloat = 4.0
    let shadowRadius: CGFloat = 4.0
    let shadowOpacity: Float = 0.5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        // Configura la apariencia de la imagen
        layer.cornerRadius = bounds.width / 2.0
        layer.masksToBounds = true
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = borderWidth
        contentMode = .scaleAspectFill
        clipsToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = CGSize(width: 0, height: 2)
        
    }
    
    // Ajusta el marco de la imagen si es necesario
    override var bounds: CGRect {
        didSet {
            layer.cornerRadius = bounds.width / 2.0
        }
    }
}

