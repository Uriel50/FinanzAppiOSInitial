//
//  LoginViewController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 18/08/23.
//

import UIKit
import CoreData
import CommonCrypto
import GoogleSignIn


class LoginViewController: UIViewController, UITextFieldDelegate  {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var keyTextField: UITextField!
    @IBOutlet weak var visibilityKey: UIButton!
    
    
    
    var repository = FinanzAppRepository()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        keyTextField.delegate = self
        
        
        let initialImage = UIImage(named: "ojocruzado")
        let resizedImage = resizeImage(image: initialImage!, targetSize: visibilityKey.frame.size)
        visibilityKey.setImage(resizedImage, for: .normal)
        keyTextField.isSecureTextEntry = true  // Asegura que la contraseña esté oculta al principio
        visibilityKey.imageView?.contentMode = .scaleAspectFit
        // Crear un UITapGestureRecognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Esto permite que otros controles reciban eventos táctiles
        view.addGestureRecognizer(tapGesture)

    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        detectStatus { isLogged in
                print("detect status es \(isLogged)")
                if isLogged {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "InicioViewSegue", sender: nil)
                    }
                } else {
  
                }
            }
    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {

        guard let email = emailTextField.text, !email.isEmpty,
              let password = keyTextField.text, !password.isEmpty else {
            showAlert(withMessage: "Por favor, rellene todos los campos.")
            return
        }
    

        repository.userEmailExists(email) { [weak self] exists in
            guard let self = self else { return }
            
            if !exists {
                DispatchQueue.main.async {
                    self.showAlert(withMessage: "No existe una cuenta con ese correo electrónico.")
                }
                return
            }
            
            let hashedPassword = self.hashPassword(password)
            
            self.repository.getUserByEmail(email: email) { user in
                DispatchQueue.main.async {
                    if let user = user, user.userKey == hashedPassword {
                        UserDefaults.standard.set(email,forKey: "userEmail")
                        self.performSegue(withIdentifier: "InicioViewSegue", sender: nil)
                        print("email \(email)")
                        
                    } else {
                        self.showAlert(withMessage: "Correo electrónico o contraseña incorrectos.")
                    }
                }
            }
        }
    }
    
    @IBAction func googleButtonPressed(_ sender: Any) {

        
        GIDSignIn.sharedInstance.signIn(withPresenting: self){
            result, error in
            if error != nil{
                print("algo salio mal .. \(error?.localizedDescription)")
            }else{
                guard let profile = result?.user else{return}
                print(profile)
                
                self.saveGoogleUserInfo()
                
                if let email = GIDSignIn.sharedInstance.currentUser?.profile?.email {
                    UserDefaults.standard.set(email, forKey: "userEmail")
                    print("email google \(email)")
                } else {
                    print("No hay un email disponible")
                }
                self.performSegue(withIdentifier: "InicioViewSegue", sender: nil)
            }
        }
    }
    
    func saveGoogleUserInfo() {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            print("No se encontró un usuario de Google.")
            return
        }
        
        let displayName = user.profile?.name ?? ""
        let email = user.profile?.email ?? ""
        
        // Crear un diccionario con los detalles del usuario
        let userDetails: [String: Any] = [
            "userName": displayName,
            "userEmail": email,
            "userSex": "?",  // Deberías tener una manera de obtener esta información
            "userKey": "****", // No deberías guardar contraseñas de esta manera
            "userNickname": displayName,
            "userLastname": displayName  // Suponiendo que el apellido está en el displayName
        ]
        
        // Obtener el contexto de NSManagedObjectContext
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let repository = FinanzAppRepository(context: context)
        
        // Verificar si el usuario ya existe
        repository.getUserByEmail(email: email) { existingUser in
            if existingUser == nil {
                // El usuario no existe, insertar nuevo usuario
                repository.insertUser(userDetails: userDetails) { success in
                    if success {
                        print("Nuevo usuario de Google guardado exitosamente.")
                    } else {
                        print("Error al guardar el usuario de Google.")
                    }
                }
            } else {
  
            }
        }
    }
    
    
    
    @IBAction func visibilityButton(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        keyTextField.isSecureTextEntry.toggle()

        let originalImage = sender.isSelected ? UIImage(named: "ojo") : UIImage(named: "ojocruzado")
        let resizedImage = resizeImage(image: originalImage!, targetSize: sender.frame.size)
        
        sender.setImage(resizedImage, for: .normal)
        sender.setImage(resizedImage, for: .selected)
        
    }
    
    
    
    func detectStatus(completion: @escaping (Bool) -> Void) {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let user = user, error == nil {
                print("El usuario está logueado: \(user)")
                completion(true)
            } else {
                print("El usuario no está logueado o hubo un error: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
            }
        }
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
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: "Aceptar", style: .default)
        alertController.addAction(acceptAction)
        present(alertController, animated: true, completion: nil)
    }

    
    
}
