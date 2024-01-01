//
//  RegisterStrategyViewController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 15/12/23.
//

import UIKit
import CoreData

class RegisterStrategyViewController: UIViewController {

    @IBOutlet weak var nameStrategy: UITextField!
    
    @IBOutlet weak var mountStrategy: UITextField!
    
    var context: NSManagedObjectContext!
    var repository: FinanzAppRepository!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        context = appDelegate.persistentContainer.viewContext
        repository = FinanzAppRepository(context: context)
        
        
        customizeTextField(nameStrategy)
        customizeTextField(mountStrategy)
        
        // Crear un UITapGestureRecognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Esto permite que otros controles reciban eventos táctiles
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showSuccessAlert() {
        let alert = UIAlertController(title: "Estrategia Creada", message: "Comienza a tomar el control de tus finanzas", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { [weak self] _ in

            self?.navigationController?.popToRootViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }


    @IBAction func saveStrategy(_ sender: UIButton) {
        guard let name = nameStrategy.text, !name.isEmpty,
              let mountText = mountStrategy.text, let balanceTotal = Double(mountText),
              let userEmail = UserDefaults.standard.string(forKey: "userEmail") else {
            // Mostrar un mensaje de error si los campos están vacíos o el userEmail no está disponible
            return
        }
        
        var userId : Int64 = 0
        repository.getUserByEmail(email: userEmail){user in
            userId = user?.userId ?? 0
        }

        // Crear el presupuesto
        var budgetDetails: [String: Any] = [
            "nameBudget": name,
            "userEmailBudget": userEmail,
            "userId": userId
        ]
        repository.insertBudget(budgetDetails: budgetDetails) { [weak self] success in
            if success {
                // Crear los totales
                self?.repository.getBudgetIdByEmail(email: userEmail) { budgetId in
                    guard let budgetId = budgetId else {

                        return
                    }
                    let totalDetails: [String: Any] = [
                        "totalIncome": 0.0,
                        "totalExpense": 0.0,
                        "balanceTotal": balanceTotal,
                        "userEmailTotal": userEmail,
                        "budgetId": budgetId
                    ]
                    self?.repository.insertTotal(totalDetails: totalDetails) { success in
                        DispatchQueue.main.async {
                            if success {
    
                                self?.showSuccessAlert()
                            } else {
               
                            }
                        }
                    }
                }
            } else {
            
            }
        }
    }
}
func customizeTextField(_ textField: UITextField) {
    // Color del texto
    textField.textColor = UIColor.white
    
    // Estilo del placeholder
    if let placeholder = textField.placeholder {
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
    }
}
