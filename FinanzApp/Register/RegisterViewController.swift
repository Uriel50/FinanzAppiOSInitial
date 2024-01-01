//
//  RegisterViewController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 18/08/23.
//

import UIKit
import CoreData
import CommonCrypto


class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {
    
    
    @IBOutlet weak var genderPickerView: UIPickerView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var nickName: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var key: UITextField!
    
    @IBOutlet weak var visibilityKey: UIButton!
    
    
    
    let genders = ["Masculino", "Femenino"]
    var repository = FinanzAppRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Asigna el delegado y el origen de datos del picker view
        genderPickerView.delegate = self
        genderPickerView.dataSource = self
        
        
        nickName.delegate = self
        name.delegate = self
        lastName.delegate = self
        email.delegate = self
        key.delegate = self
        
        validateFields()
        
        let initialImage = UIImage(named: "ojocruzado")
        let resizedImage = resizeImage(image: initialImage!, targetSize: visibilityKey.frame.size)
        visibilityKey.setImage(resizedImage, for: .normal)
        key.isSecureTextEntry = true  // Asegura que la contraseña esté oculta al principio
        visibilityKey.imageView?.contentMode = .scaleAspectFit
        
        // Crear un UITapGestureRecognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Esto permite que otros controles reciban eventos táctiles
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // Número de componentes en el picker view (en este caso, solo uno)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    // Número de filas en el picker view (cantidad de opciones)
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let gender = genders[row]
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10) // Cambia el tamaño del texto aquí
        ]
        return NSAttributedString(string: gender, attributes: attributes)
    }
    
    
    // Acción cuando se selecciona una opción del picker view
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedGender = genders[row]
        print("Selected Gender: \(selectedGender)")
        // Aquí puedes realizar cualquier acción adicional basada en la selección
        
        
    
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
            validateFields()
    }

    
    func validateFields() {
        let allFieldsFilled = !(nickName.text?.isEmpty ?? true) &&
                              !(name.text?.isEmpty ?? true) &&
                              !(lastName.text?.isEmpty ?? true) &&
                              !(email.text?.isEmpty ?? true) &&
                              !(key.text?.isEmpty ?? true) &&
                              isValidEmail(email.text ?? "")

        registerButton.isEnabled = allFieldsFilled
    }
    
    func hashPassword(_ password: String) -> String {
        if let data = password.data(using: .utf8) {
            var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
            data.withUnsafeBytes {
                _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
            }
            return hash.map { String(format: "%02x", $0) }.joined()
        }
        return ""
    }


    func showAlert(withMessage message: String) {
        let alertController = UIAlertController(title: "Alerta", message: message, preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: "Aceptar", style: .default) { _ in
            // Acciones a realizar cuando se toca el botón "Aceptar", si es necesario
        }
        alertController.addAction(acceptAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showSuccessAlert() {
        let alertController = UIAlertController(title: "Éxito", message: "Usuario creado correctamente", preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: "Iniciar Sesion", style: .default) { [weak self] _ in
            // Volver a la vista anterior
            self?.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(acceptAction)
        present(alertController, animated: true, completion: nil)
    }


    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Determinar qué ratio usar para escalar la imagen
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // Redimensionar la imagen
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? image
    }

    @IBAction func visibilityKey(_ sender: UIButton) {
        sender.isSelected.toggle()
        key.isSecureTextEntry.toggle()

        let originalImage = sender.isSelected ? UIImage(named: "ojo") : UIImage(named: "ojocruzado")
        let resizedImage = resizeImage(image: originalImage!, targetSize: sender.frame.size)
        
        sender.setImage(resizedImage, for: .normal)
        sender.setImage(resizedImage, for: .selected)
    }

    
    
    
    
    
    
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        guard let nickname = nickName.text,
                  let userName = name.text,
                  let userLastName = lastName.text,
                  let userEmail = email.text,
                  let userKey = key.text,
                  !nickname.isEmpty,
                  !userName.isEmpty,
                  !userLastName.isEmpty,
                  isValidEmail(userEmail),
                  !userKey.isEmpty else {
                print("Error: No se pudo obtener la información del formulario")
                return
            }

            let selectedGenderIndex = genderPickerView.selectedRow(inComponent: 0)
            let gender = genders[selectedGenderIndex]
            let hashedKey = hashPassword(userKey)

            repository.userEmailExists(userEmail) { [weak self] exists in
                DispatchQueue.main.async {
                    guard !exists else {
                        print("Correo electrónico ya registrado.")
                        self?.showAlert(withMessage: "Ya existe un usuario con el correo electrónico ingresado.")
                        return
                    }

                    let userDetails: [String: Any] = [
                        "userNickname": nickname,
                        "userName": userName,
                        "userLastname": userLastName,
                        "userSex": gender,
                        "userEmail": userEmail,
                        "userKey": hashedKey
                    ]

                    self?.repository.insertUser(userDetails: userDetails) { success in
                        if success {
                            // Manejar éxito
                            print("Usuario guardado con éxito")
                            self?.showSuccessAlert()
                            
                        } else {
                            // Manejar error
                            print("Error al guardar el usuario")
                            // Considera mostrar un mensaje de error al usuario
                        }
                    }
                }
            }
        }
}
