//
//  ReminderHomeTableViewController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 15/12/23.
//

import UIKit
import CoreData

class ReminderHomeTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet var remiderHomeView: UITableView!
    
    
    var fetchedResultsController: NSFetchedResultsController<ReminderEntity>!
        let repository = FinanzAppRepository()
        let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        
        override func viewDidLoad() {
            super.viewDidLoad()
            initializeFetchedResultsController()
        }

        func initializeFetchedResultsController() {
            let fetchRequest: NSFetchRequest<ReminderEntity> = ReminderEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "userEmailReminder == %@", email)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "reminderDate", ascending: true)]
            fetchRequest.fetchLimit = 2  // Limitar los resultados a los dos primeros

            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: repository.context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self

            do {
                try fetchedResultsController.performFetch()
                remiderHomeView.reloadData()
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

        // MARK: - NSFetchedResultsControllerDelegate Methods
        func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            remiderHomeView.beginUpdates()
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            remiderHomeView.endUpdates()
        }

        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                        didChange anObject: Any,
                        at indexPath: IndexPath?,
                        for type: NSFetchedResultsChangeType,
                        newIndexPath: IndexPath?) {
            switch type {
            case .insert:
                if let newIndexPath = newIndexPath {
                    remiderHomeView.insertRows(at: [newIndexPath], with: .fade)
                }
            case .delete:
                if let indexPath = indexPath {
                    remiderHomeView.deleteRows(at: [indexPath], with: .fade)
                }
            case .update:
                if let indexPath = indexPath {
                    let cell = remiderHomeView.cellForRow(at: indexPath) as! ReminderHomeCell
                    let reminder = fetchedResultsController.object(at: indexPath)
                    // Configurar tu celda con los datos del recordatorio
                }
            case .move:
                if let indexPath = indexPath, let newIndexPath = newIndexPath {
                    remiderHomeView.moveRow(at: indexPath, to: newIndexPath)
                }
            @unknown default:
                fatalError("NSFetchedResultsController change type not handled: \(type)")
            }
        }

        // MARK: - Table view data source
        
        override func numberOfSections(in tableView: UITableView) -> Int {
            return fetchedResultsController.sections?.count ?? 0
        }

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            guard let sections = fetchedResultsController.sections else { return 0 }
            return sections[section].numberOfObjects
        }

        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderHomeCell", for: indexPath) as! ReminderHomeCell
            let reminder = fetchedResultsController.object(at: indexPath)
            cell.configure(with: reminder)
            
            let categoryName = reminder.reminderCategory ?? "Otro"
            let imageName = imageNameForCategory(categoryName)
            if let image = UIImage(named: imageName) {
                let resizedImage = resizeImage(image: image, targetSize: cell.imageReminderHome.frame.size) // ajusta el tamaño según sea necesario
                cell.imageReminderHome.image = resizedImage
            }
            // Configurar tu celda con los datos del recordatorio
            return cell
        }

        override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 80 // Altura de las celdas
        }
        
        // ... Otros métodos necesarios, como la confirmación y eliminación de recordatorios ...
    }
