//
//  AddIncomeViewController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 16/12/23.
//

import UIKit


class AddIncomeViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var nameIncome: UITextField!
    
    @IBOutlet weak var pickerCategoryIncome: UIPickerView!
    
    @IBOutlet weak var mountIncome: UITextField!
    
    let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
    
    let categories = ["Salario","Inversiones","Aquileres","Pension","Regalias","Otros"]
    
    var selectedCategory: String?
    
    let repository = FinanzAppRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerCategoryIncome.dataSource = self
        pickerCategoryIncome.delegate = self
        selectedCategory = categories.first
    }
    
    @IBAction func saveIncomeButton(_ sender: UIBarButtonItem) {
        guard let name = nameIncome.text, !name.isEmpty,
                      let amountText = mountIncome.text, let amount = Double(amountText),
                      let category = selectedCategory else {
                    // Mostrar alerta si falta información
                    return
                }

                // Primero, obtener el budgetId
                repository.getBudgetIdByEmail(email: email) { [weak self] budgetId in
                    guard let self = self, let budgetId = budgetId else {
                        // Manejar el caso de no encontrar el presupuesto
                        return
                    }

                    let incomeDetails: [String: Any] = [
                        "incomeName": name,
                        "incomeMount": amount,
                        "incomeCategory": category,
                        "incomeDate": self.getCurrentDate(),
                        "userEmailIncome": self.email,
                        "budgetId": budgetId
                    ]

                    self.repository.insertIncome(incomeDetails: incomeDetails) { success in
                        if success {
                            self.updateTotalForIncome(incomeAmount: amount)
                        } else {
                            // Manejar el error
                        }
                    }
                }
    }
    
    @IBAction func cancelIncomeButton(_ sender: UIBarButtonItem) {
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

        private func updateTotalForIncome(incomeAmount: Double) {
            repository.getTotalByEmail(email: email) { [weak self] totalEntity in
                guard let self = self, let totalEntity = totalEntity else {
                    // Manejar el caso de no encontrar el total
                    return
                }

                let updatedIncomeTotal = totalEntity.totalIncome + incomeAmount
                let updatedBalance = updatedIncomeTotal + totalEntity.balanceTotal

                var totalDetails: [String: Any] = [
                    "totalIncome": updatedIncomeTotal,
                    "balanceTotal": updatedBalance
                ]

                self.repository.updateTotal(total: totalEntity, totalDetails: totalDetails) { success in
                    DispatchQueue.main.async {
                        if success {
                            self.showAlert(title: "Éxito", message: "Ingreso agregado correctamente.")
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
