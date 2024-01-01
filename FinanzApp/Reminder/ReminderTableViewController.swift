//
//  ReminderTableViewController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 14/12/23.
//

import UIKit
import CoreData

class ReminderTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet var reminderTable: UITableView!
    
    @IBOutlet var emptyReminderView: UIView!
    
    @IBOutlet weak var createReminderButton: UIBarButtonItem!
    
    let repository = FinanzAppRepository()
    var fetchedResultsController: NSFetchedResultsController<ReminderEntity>!
    let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchedResultsController()
        
    }
    
    func updateView() {
        let hasReminders = fetchedResultsController.fetchedObjects?.count ?? 0 > 0
        reminderTable.backgroundView = hasReminders ? nil : emptyReminderView
        reminderTable.separatorStyle = hasReminders ? .singleLine : .none
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }

    func initializeFetchedResultsController() {
        let fetchRequest: NSFetchRequest<ReminderEntity> = ReminderEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userEmailReminder == %@", email)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "reminderDate", ascending: true)]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: repository.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func imageNameForCategory(_ category: String) -> String {
        switch category {
        case "Renta/Hipoteca":
            return "renta"
        case "Luz/Electricidad":
            return "medidor-de-electricidad"
        case "Agua":
            return "agua-potable"
        case "Internet/Telefono":
            return "wifi"
        case "Tv/Stream":
            return "televisor"
        case "Automotriz":
            return "car_855270"
        case "Tarjeta de credito":
            return "credit-card"
        case "Otro":
            return "validando-billete"
            
        default:
            return "validando-billete"
        }
    }




    // MARK: - NSFetchedResultsControllerDelegate Methods
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateView()
        reminderTable.endUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        reminderTable.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                reminderTable.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                reminderTable.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                let cell = reminderTable.cellForRow(at: indexPath) as! ReminderCell
                let reminder = fetchedResultsController.object(at: indexPath)
                cell.configure(with: reminder)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                reminderTable.moveRow(at: indexPath, to: newIndexPath)
            }
        @unknown default:
            fatalError("NSFetchedResultsController change type not handled: \(type)")
        }
    }

    // MARK: - Table view data source
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfObjects = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        if numberOfObjects == 0 {
            // No hay recordatorios, muestra la vista vacía
            emptyReminderView.isHidden = false
        } else {
            // Hay recordatorios, oculta la vista vacía
            emptyReminderView.isHidden = true
        }
        return numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as! ReminderCell
        let reminder = fetchedResultsController.object(at: indexPath)
        cell.configure(with: reminder)
        
        let categoryName = reminder.reminderCategory ?? "Otro"
        let imageName = imageNameForCategory(categoryName)
        if let image = UIImage(named: imageName) {
            let resizedImage = resizeImage(image: image, targetSize: cell.imageReminder.frame.size) // ajusta el tamaño según sea necesario
            cell.imageReminder.image = resizedImage
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115 // Altura de las celdas
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true // Permite la edición de las filas
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            confirmAndDeleteReminder(at: indexPath)
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedReminder = fetchedResultsController.object(at: indexPath)

        if let navController = storyboard?.instantiateViewController(withIdentifier: "UpdateReminderNavController") as? UINavigationController,
           let updateVC = navController.viewControllers.first as? UpdateReminderViewController {
            updateVC.reminderToEdit = selectedReminder

            self.present(navController, animated: true, completion: nil)
        }
    }



    
    func confirmAndDeleteReminder(at indexPath: IndexPath) {
        let reminderToDelete = fetchedResultsController.object(at: indexPath)

        let alert = UIAlertController(title: "Eliminar Recordatorio", message: "¿Estás seguro de que quieres eliminar este recordatorio?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Eliminar", style: .destructive) { [weak self] _ in
            self?.repository.deleteReminder(reminder: reminderToDelete) { success in
                DispatchQueue.main.async {
                    if !success {
                        // Mostrar un mensaje de error si es necesario
                    }
                    // NSFetchedResultsController se encargará de actualizar la UI
                }
            }
        }
        alert.addAction(deleteAction)

        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
    
        
        // MARK: - Navigation
        
        // Implement the prepare for segue method if you're using segues to add/edit reminders
        
        // Implement the method to handle the creation of a new reminder
    @IBAction func createReminderButtonTapped(_ sender: UIBarButtonItem) {
        // Handle the creation of a new reminder
    }

}
