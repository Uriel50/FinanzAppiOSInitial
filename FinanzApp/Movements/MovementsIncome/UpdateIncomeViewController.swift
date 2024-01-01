//
//  UpdateIncomeViewController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 31/12/23.
//

import UIKit
import CoreData

class UpdateIncomeViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    @IBOutlet weak var nameIncomeTextField: UITextField!
    @IBOutlet weak var categoryIncomePicker: UIPickerView!
    @IBOutlet weak var amountIncomeTextField: UITextField!
    
    var incomeToEdit: IncomeEntity?
    let categories = ["Salario", "Inversiones", "Aquileres", "Pension", "Regalias", "Otros"]
    var selectedCategory: String?
    let repository = FinanzAppRepository()
    let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""

    override func viewDidLoad() {
        super.viewDidLoad()
        categoryIncomePicker.dataSource = self
        categoryIncomePicker.delegate = self
        configureViewWithIncome()
    }

    private func configureViewWithIncome() {
        guard let income = incomeToEdit else { return }
        nameIncomeTextField.text = income.incomeName
        amountIncomeTextField.text = String(income.incomeMount)

        if let index = categories.firstIndex(of: income.incomeCategory) {
            categoryIncomePicker.selectRow(index, inComponent: 0, animated: false)
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

    @IBAction func updateIncomeButtonPressed(_ sender: UIBarButtonItem) {
        guard let income = incomeToEdit,
              let name = nameIncomeTextField.text, !name.isEmpty,
              let amountText = amountIncomeTextField.text, !amountText.isEmpty,
              let newAmount = Double(amountText),
              let category = selectedCategory else {
            showEmptyFieldsAlert()
            return
        }
        
        let oldAmount = income.incomeMount
        let amountDifference = newAmount - oldAmount
        
        if name == income.incomeName &&
           newAmount == oldAmount &&
           category == income.incomeCategory {
            showAlertForNoChanges()
            return
        }

        income.incomeName = name
        income.incomeMount = newAmount
        income.incomeCategory = category

        repository.updateIncome(income: income, incomeDetails: [:]) { success in
            DispatchQueue.main.async {
                if success {
                    
                    self.updateTotalForIncomeChange(amountDifference: amountDifference)
                } else {
                    self.showAlert(title: "Error", message: "No se pudo actualizar el ingreso.")
                }
            }
        }
    }
    
    
    private func updateTotalForIncomeChange(amountDifference: Double) {
        repository.getTotalByEmail(email: email) { [weak self] totalEntity in
            guard let self = self, let totalEntity = totalEntity else {
                
                return
            }

            let updatedIncomeTotal = totalEntity.totalIncome + amountDifference
            let updatedBalance = totalEntity.balanceTotal + amountDifference

            var totalDetails: [String: Any] = [
                "totalIncome": updatedIncomeTotal,
                "balanceTotal": updatedBalance
            ]

            self.repository.updateTotal(total: totalEntity, totalDetails: totalDetails) { success in
                DispatchQueue.main.async {
                    if success {
                        self.showAlert(title: "Éxito", message: "Ingreso actualizado con éxito.")
                    } else {
                    }
                }
            }
        }
    }

    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
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
        let alert = UIAlertController(title: "Sin Cambios", message: "No se han realizado cambios en el ingreso.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showEmptyFieldsAlert() {
        let alert = UIAlertController(title: "Campos Requeridos", message: "Por favor, rellena todos los campos para continuar.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
