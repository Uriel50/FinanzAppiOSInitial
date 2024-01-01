//
//  UpdateReminderViewController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 31/12/23.
//

import UIKit
import CoreData

class UpdateReminderViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    

    
    @IBOutlet weak var reminderNameTextField: UITextField!
    @IBOutlet weak var reminderAmountTextField: UITextField!
    @IBOutlet weak var reminderDatePicker: UIDatePicker!
    @IBOutlet weak var reminderCategoryPicker: UIPickerView!
    

    // Variables
    var reminderToEdit: ReminderEntity?
    let categories = ["Renta/Hipoteca", "Luz/Electricidad", "Agua", "Internet/Telefono", "Tv/Stream", "Automotriz", "Tarjeta de credito", "Otro"]
    var selectedCategory: String?
    let repository = FinanzAppRepository()
    let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""

    override func viewDidLoad() {
        super.viewDidLoad()
        reminderCategoryPicker.dataSource = self
        reminderCategoryPicker.delegate = self
        configureViewWithReminder()
    }

    private func configureViewWithReminder() {
        guard let reminder = reminderToEdit else { return }

        // Configurar campos de texto
        reminderNameTextField.text = reminder.reminderTitle
        reminderAmountTextField.text = String(reminder.reminderMount)

        // Configurar UIPickerView
        if let index = categories.firstIndex(of: reminder.reminderCategory) {
            reminderCategoryPicker.selectRow(index, inComponent: 0, animated: false)
            selectedCategory = categories[index]
        }

        // Configurar UIDatePicker
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        if let date = dateFormatter.date(from: reminder.reminderDate) {
            dateFormatter.dateFormat = "HH:mm"
            if let time = dateFormatter.date(from: reminder.hour) {
                let combinedDateTime = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: time), minute: Calendar.current.component(.minute, from: time), second: 0, of: date)
                reminderDatePicker.date = combinedDateTime ?? Date()
            }
        }
    }

    // Métodos del UIPickerView
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
    
    
    @IBAction func updateButtonPressed(_ sender: UIBarButtonItem) {
        guard let name = reminderNameTextField.text, !name.isEmpty,
              let amountText = reminderAmountTextField.text, !amountText.isEmpty,
              let amount = Double(amountText),
              let category = selectedCategory,
              let reminder = reminderToEdit else {
            showEmptyFieldsAlert()
            return
        }

        let reminderDate = reminderDatePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let formattedDate = dateFormatter.string(from: reminderDate)
        dateFormatter.dateFormat = "HH:mm"
        let formattedTime = dateFormatter.string(from: reminderDate)
        
        if name == reminder.reminderTitle,
           amount == reminder.reminderMount,
           category == reminder.reminderCategory,
           formattedDate == reminder.reminderDate,
           formattedTime == reminder.hour {
            showAlertForNoChanges()
            return
        }

        reminder.reminderTitle = name
        reminder.reminderCategory = category
        reminder.reminderDate = formattedDate
        reminder.hour = formattedTime
        reminder.reminderMount = amount
        reminder.userEmailReminder = email

        repository.updateReminder(reminder: reminder, reminderDetails: [:]) { success in
            DispatchQueue.main.async {
                if success {
                    self.showAlert(title: "Éxito", message: "Recordatorio actualizado con éxito.")
                } else {
                    self.showAlert(title: "Error", message: "No se pudo actualizar el recordatorio.")
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
        let alert = UIAlertController(title: "Sin Cambios", message: "No se han realizado cambios en el recordatorio.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showEmptyFieldsAlert() {
        let alert = UIAlertController(title: "Campos Requeridos", message: "Por favor, rellena todos los campos para continuar.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    
}
