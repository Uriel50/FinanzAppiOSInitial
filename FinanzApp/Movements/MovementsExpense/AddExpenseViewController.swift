//
//  AddExpenseViewController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 16/12/23.
//

import UIKit

class AddExpenseViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var nameExpese: UITextField!
    
    @IBOutlet weak var expensePickerCategory: UIPickerView!
    
    
    @IBOutlet weak var mountExpense: UITextField!
    
    let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
    
    let categories = ["Comida","Transporte","Vivienda","Entretenimiento","Salud","Educacion","Impuestos","Viajes","Otros"]
    
    var selectedCategory: String?
    
    let repository = FinanzAppRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        expensePickerCategory.dataSource = self
        expensePickerCategory.delegate = self
        selectedCategory = categories.first
    }
    
    
    @IBAction func saveExpenseButton(_ sender: UIBarButtonItem) {
        guard let name = nameExpese.text, !name.isEmpty,
                      let amountText = mountExpense.text, let amount = Double(amountText),
                      let category = selectedCategory else {
                    // Mostrar alerta si falta información
                    return
                }

                // Primero, obtener el budgetId
                repository.getBudgetIdByEmail(email: email) { [weak self] budget in
                    guard let self = self, let budgetId = budget else {
                        // Manejar el caso de no encontrar el presupuesto
                        return
                    }
                    
                

                    let expenseDetails: [String: Any] = [
                        "expenseName": name,
                        "expenseMount": amount,
                        "expenseCategory": category,
                        "expenseDate": self.getCurrentDate(),
                        "userEmailExpense": self.email,
                        "budgetId": budgetId
                    ]

                    self.repository.insertExpense(expenseDetails: expenseDetails) { success in
                        if success {
                            self.updateTotalForExpense(expenseAmount: amount)
                        } else {
                            // Manejar el error
                        }
                    }
                }
    }
    
    
    @IBAction func cancelExpenseButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // UIPickerView DataSource and Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categories[row]
    }

    private func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: Date())
    }

    private func updateTotalForExpense(expenseAmount: Double) {
        repository.getTotalByEmail(email: email) { [weak self] totalEntity in
            guard let self = self, let totalEntity = totalEntity else {
                // Manejar el caso de no encontrar el total
                return
            }

            let updatedExpenseTotal = totalEntity.totalExpense + expenseAmount
            let updatedBalance = totalEntity.balanceTotal - updatedExpenseTotal

            var totalDetails: [String: Any] = [
                "totalExpense": updatedExpenseTotal,
                "balanceTotal": updatedBalance
            ]

            self.repository.updateTotal(total: totalEntity, totalDetails: totalDetails) { success in
                DispatchQueue.main.async {
                    if success {
                        self.showAlert(title: "Éxito", message: "Gasto agregado correctamente.")
                    } else {
                        // Manejar el error
                    }
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
}
