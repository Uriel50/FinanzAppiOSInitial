//
//  BalanceViewController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 14/12/23.
//

import UIKit
import CoreData

class BalanceViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mountIncomeBalance: UILabel!
    
    @IBOutlet weak var mountExpenseBalance: UILabel!
    
    
    @IBOutlet weak var mountTotalBalance: UILabel!
    
    
    var repository: FinanzAppRepository!
       var fetchedResultsController: NSFetchedResultsController<TotalsEntity>!

       override func viewDidLoad() {
           super.viewDidLoad()
           repository = FinanzAppRepository()
           initializeFetchedResultsController()
           loadTotalsData()
       }

       func initializeFetchedResultsController() {
           let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
           let predicate = NSPredicate(format: "userEmailTotal == %@", email)
           let sortDescriptor = NSSortDescriptor(key: #keyPath(TotalsEntity.idTotal), ascending: true)

           fetchedResultsController = repository.fetchedResultsControllerForEntity(entityName: "TotalsEntity", sortDescriptors: [sortDescriptor], predicate: predicate) as NSFetchedResultsController<TotalsEntity>
           fetchedResultsController.delegate = self
       }

       func loadTotalsData() {
           do {
               try fetchedResultsController.performFetch()
               updateBalanceUI()
           } catch {
               print("Error al cargar datos: \(error)")
           }
       }

       func updateBalanceUI() {
           if let totals = fetchedResultsController.fetchedObjects?.first {
               mountIncomeBalance.text = "+$\(totals.totalIncome)"
               mountExpenseBalance.text = "-$\(totals.totalExpense)"
               mountTotalBalance.text = "$\(totals.balanceTotal)"
           }
       }

       // NSFetchedResultsControllerDelegate methods
       func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
           updateBalanceUI()
       }
   }
