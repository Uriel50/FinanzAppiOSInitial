//
//  AddReminderViewController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 14/12/23.
//

import UIKit

class AddReminderViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
 
    
    
    
    @IBOutlet weak var reminderCategory: UIPickerView!
    
    @IBOutlet weak var reminderName: UITextField!
    
    
    @IBOutlet weak var reminderMount: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var reminderDatePicker: UIDatePicker!
    
    let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
    
    let categories = ["Renta/Hipoteca", "Luz/Electricidad", "Agua", "Internet/Telefono","Tv/Stream","Automotriz","Tarjeta de credito","Otro"]
    var selectedCategory: String?
    
    let repository = FinanzAppRepository()
    
    var editingReminder: ReminderEntity?

    override func viewDidLoad() {
        super.viewDidLoad()
        reminderCategory.dataSource = self
        reminderCategory.delegate = self
        selectedCategory = categories.first
        configureForEditing()

    }
    
    private func configureForEditing() {
            if let reminder = editingReminder {
            // Configuración para modo de edición
            reminderName.text = reminder.reminderTitle
            reminderMount.text = String(reminder.reminderMount)

            // Configurar el UIPickerView
            if let index = categories.firstIndex(of: reminder.reminderCategory) {
                reminderCategory.selectRow(index, inComponent: 0, animated: false)
                selectedCategory = categories[index]
            }

            // Configurar el UIDatePicker
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            if let date = dateFormatter.date(from: reminder.reminderDate) {
                dateFormatter.dateFormat = "HH:mm"
                if let time = dateFormatter.date(from: reminder.hour) {
                    let combinedDateTime = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: time), minute: Calendar.current.component(.minute, from: time), second: 0, of: date)
                    reminderDatePicker.date = combinedDateTime ?? Date()
                }
            }

            // Cambiar el título del botón de Guardar a Actualizar
            saveButton.title = "Actualizar"
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
    
    func showEmptyFieldsAlert() {
        let alert = UIAlertController(title: "Campos Requeridos", message: "Por favor, rellena todos los campos para continuar.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        
        guard let name = reminderName.text, !name.isEmpty,
                 let amountText = reminderMount.text, !amountText.isEmpty,
                 let amount = Double(amountText),
                 let category = selectedCategory else {
               showEmptyFieldsAlert()
               return
           }

           let reminderDate = reminderDatePicker.date
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "dd/MM/yyyy"
           let formattedDate = dateFormatter.string(from: reminderDate)
           dateFormatter.dateFormat = "HH:mm"
           let formattedTime = dateFormatter.string(from: reminderDate)

           if let reminder = editingReminder {
               // Actualizando un recordatorio existente
               reminder.reminderTitle = name
               reminder.reminderCategory = category
               reminder.reminderDate = formattedDate
               reminder.hour = formattedTime
               reminder.reminderMount = amount
               reminder.userEmailReminder = email

               repository.updateReminder(reminder: reminder, reminderDetails: [:]) { success in
                   DispatchQueue.main.async {
                       if success {
                           self.showAlert(title: "Éxito", message: "Recordatorio actualizado con éxito.") {
                               self.dismiss(animated: true, completion: nil)
                           }
                       } else {
                           self.showAlert(title: "Error", message: "No se pudo actualizar el recordatorio.")
                       }
                   }
               }
           } else {
               repository.getUserById(email: email) { [weak self] userEntity in
                               guard let self = self, let userEntity = userEntity else {
                                   DispatchQueue.main.async {
                                       self?.showAlert(title: "Error", message: "No se pudo obtener la información del usuario.")
                                   }
                                   return
                               }

                               let userId = userEntity.userId // Asumiendo que 'userId' es una propiedad de 'UserEntity'

                               let reminderDetails: [String: Any] = [
                                   "reminderTitle": name,
                                   "reminderCategory": category,
                                   "reminderDate": formattedDate,
                                   "hour": formattedTime,
                                   "reminderMount": amount,
                                   "userEmailReminder": self.email,
                                   "userId": userId
                               ]
                               
                               self.repository.insertReminder(reminderDetails: reminderDetails) { success in
                                   DispatchQueue.main.async {
                                       if success {
                                           self.showAlert(title: "Éxito", message: "Recordatorio creado con éxito.") {
                                               self.dismiss(animated: true, completion: nil)
                                           }
                                       } else {
                                           self.showAlert(title: "Error", message: "No se pudo guardar el recordatorio.")
                                       }
                                   }
                               }
                           }
           }
        }

        func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                completion?()
            }))
            self.present(alert, animated: true, completion: nil)
        }
}
