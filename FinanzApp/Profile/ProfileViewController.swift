//
//  PerfilViewController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 11/12/23.
//

import UIKit
import GoogleSignIn

class ProfileViewController: UIViewController {
    
    

    @IBOutlet weak var imageProfile: RoundImageViewWithBorder!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var sexLabel: UILabel!
    
    let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
    
    let repository = FinanzAppRepository()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Obtener los detalles del usuario
            repository.getUserByEmail(email: email) { [weak self] userEntity in
                DispatchQueue.main.async {
                    if let user = userEntity {
                        // Configurar los labels con la información del usuario
                        self?.nameLabel.text = user.userName
                        self?.userLabel.text = "@"+user.userNickname
                        self?.emailLabel.text = user.userEmail
                        self?.sexLabel.text = user.userSex
                        if GIDSignIn.sharedInstance.currentUser != nil {
                            let googleUser = GIDSignIn.sharedInstance.currentUser
                            
                            // Cargar la imagen de perfil de Google
                            if let profilePicURL = googleUser?.profile?.imageURL(withDimension: 200) {
                                self?.loadImage(from: profilePicURL)
                            }
                        }
    
                    }
                }
            }

    }
    
    func loadImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageProfile.image = image
                }
            }
        }
    }
    
    
    

    @IBAction func singOutGoogleButton(_ sender: Any) {
        GIDSignIn.sharedInstance.signOut()
        navigateToLoginViewController()
    }
    
    func navigateToLoginViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            guard let window = UIApplication.shared.windows.first else { return }

            // Configura el nuevo rootViewController y una transición de fundido
            window.rootViewController = loginViewController

            // Anima la transición
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }

}
