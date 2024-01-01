//
//  TapBarHomeController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 18/08/23.
//

import UIKit

class TapBarHomeController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Supongamos que estamos trabajando con el primer ítem de la barra de pestañas
        // Primer ítem de la barra de pestañas
        if let firstTab = tabBar.items?[0] {
            if let originalImage = UIImage(named: "home") {
                let scaledImage = resizeImage(originalImage, targetSize: CGSize(width: 20, height: 20)) // Cambia el tamaño deseado aquí
                
                // Asigna la imagen redimensionada al ítem de la barra de pestañas
                firstTab.image = scaledImage
            }
        }
        
        // Segundo ítem de la barra de pestañas
        if let secondTab = tabBar.items?[1] {
            if let originalImage = UIImage(named: "grafico-circular") {
                let scaledImage = resizeImage(originalImage, targetSize: CGSize(width: 20, height: 20)) // Cambia el tamaño deseado aquí
                
                // Asigna la imagen redimensionada al ítem de la barra de pestañas
                secondTab.image = scaledImage
            }
        }
        
        if let thirdTab = tabBar.items?[2] {
            if let originalImage = UIImage(named: "transaccion") {
                let scaledImage = resizeImage(originalImage, targetSize: CGSize(width: 20, height: 20)) // Cambia el tamaño deseado aquí
                
                // Asigna la imagen redimensionada al ítem de la barra de pestañas
                thirdTab.image = scaledImage
            }
        }
        if let fourTab = tabBar.items?[3] {
            if let originalImage = UIImage(named: "reminder") {
                let scaledImage = resizeImage(originalImage, targetSize: CGSize(width: 20, height: 20)) // Cambia el tamaño deseado aquí
                
                // Asigna la imagen redimensionada al ítem de la barra de pestañas
                fourTab.image = scaledImage
            }
        }
        func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
            let size = image.size
            
            let widthRatio = targetSize.width / size.width
            let heightRatio = targetSize.height / size.height
            
            let newSize: CGSize
            if widthRatio > heightRatio {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            }
            
            let rect = CGRect(origin: .zero, size: newSize)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage ?? UIImage()
        }
        
        
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
    }
}
