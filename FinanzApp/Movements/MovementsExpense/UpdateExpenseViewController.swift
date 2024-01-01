//
//  UpdateExpenseViewController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 31/12/23.
//

import UIKit

class UpdateExpenseViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    @IBOutlet weak var nameExpenseTextField: UITextField!
    @IBOutlet weak var categoryExpensePicker: UIPickerView!
    @IBOutlet weak var amountExpenseTextField: UITextField!
    
    
    
    var expenseToEdit: ExpenseEntity?
    let categories = ["Comida", "Transporte", "Vivienda", "Entretenimiento", "Salud", "Educacion", "Impuestos", "Viajes", "Otros"]
    var selectedCategory: String?
    let repository = FinanzAppRepository()
    let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""

    override func viewDidLoad() {
        super.viewDidLoad()
        categoryExpensePicker.dataSource = self
        categoryExpensePicker.delegate = self
        configureViewWithExpense()
        print("\(expenseToEdit)")
    }
    
    private func configureViewWithExpense() {
        guard let expense = expenseToEdit else { return }
        nameExpenseTextField.text = expense.expenseName
        amountExpenseTextField.text = String(expense.expenseMount)

        if let index = categories.firstIndex(of: expense.expenseCategory) {
            categoryExpensePicker.selectRow(index, inComponent: 0, animated: false)
            selectedCategory = categories[index]
        }
    }
    
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
    
    @IBAction func updateExpenseButton(_ sender: UIBarButtonItem) {
        guard let expense = expenseToEdit,
              let name = nameExpenseTextField.text, !name.isEmpty,
              let amountText = amountExpenseTextField.text, !amountText.isEmpty,
              let newAmount = Double(amountText),
              let category = selectedCategory else {
            showEmptyFieldsAlert()
            return
        }

        let oldAmount = expense.expenseMount
        let amountDifference = newAmount - oldAmount

        if name == expense.expenseName &&
           newAmount == oldAmount &&
           category == expense.expenseCategory {
            showAlertForNoChanges()
            return
        }

        expense.expenseName = name
        expense.expenseMount = newAmount
        expense.expenseCategory = category

        repository.updateExpense(expense: expense, expenseDetails: [:]) { success in
            DispatchQueue.main.async {
                if success {
                    self.updateTotalForExpenseChange(amountDifference: amountDifference)
                } else {
                    self.showAlert(title: "Error", message: "No se pudo actualizar el gasto.")
                }
            }
        }
        
    }
    
    private func updateTotalForExpenseChange(amountDifference: Double) {
        repository.getTotalByEmail(email: email) { [weak self] totalEntity in
            guard let self = self, let totalEntity = totalEntity else {
               
                return
            }

    
            let updatedExpenseTotal = totalEntity.totalExpense + amountDifference
            let updatedBalance = totalEntity.balanceTotal - amountDifference

            var totalDetails: [String: Any] = [
                "totalExpense": updatedExpenseTotal,
                "balanceTotal": updatedBalance
            ]

            // Llamar al método de actualización del repositorio
            self.repository.updateTotal(total: totalEntity, totalDetails: totalDetails) { success in
                DispatchQueue.main.async {
                    if success {
                        // Mostrar alerta de éxito y cerrar la vista
                        self.showAlert(title: "Éxito", message: "Gasto actualizado con éxito.")
                    } else {
                    }
                }
            }
        }
    }
    
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func showAlertForNoChanges() {
        let alert = UIAlertController(title: "Sin Cambios", message: "No se han realizado cambios en el gasto.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showEmptyFieldsAlert() {
        let alert = UIAlertController(title: "Campos Requeridos", message: "Por favor, rellena todos los campos para continuar.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
