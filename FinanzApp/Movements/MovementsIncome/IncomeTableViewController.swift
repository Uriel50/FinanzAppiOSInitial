//
//  IncomeTableViewController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 16/12/23.
//

import UIKit
import CoreData

class IncomeTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet var tableIncomeView: UITableView!
    
    
    @IBOutlet var emptyIncomeView: UIView!
    
    let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        let repository = FinanzAppRepository()
        var fetchedResultsController: NSFetchedResultsController<IncomeEntity>!

        override func viewDidLoad() {
            super.viewDidLoad()
            initializeFetchedResultsController()
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            updateView()
            tableView.reloadData()
        }

        private func initializeFetchedResultsController() {
            let fetchRequest: NSFetchRequest<IncomeEntity> = IncomeEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "userEmailIncome == %@", email)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "incomeDate", ascending: true)]

            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: repository.context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self

            do {
                try fetchedResultsController.performFetch()
                updateView()
            } catch {
                fatalError("IncomeTableViewController: No se pudo realizar la operación fetch: \(error)")
            }
        }

        private func updateView() {
            DispatchQueue.main.async {
                let hasIncomes = self.fetchedResultsController.fetchedObjects?.count ?? 0 > 0
                self.tableIncomeView.backgroundView = hasIncomes ? nil : self.emptyIncomeView
                self.tableIncomeView.separatorStyle = hasIncomes ? .singleLine : .none
            }
        }

        // MARK: - NSFetchedResultsControllerDelegate Methods

        func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            updateView()
            tableIncomeView.beginUpdates()
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            tableIncomeView.endUpdates()
        }

        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                        didChange anObject: Any,
                        at indexPath: IndexPath?,
                        for type: NSFetchedResultsChangeType,
                        newIndexPath: IndexPath?) {
            switch type {
            case .insert:
                if let newIndexPath = newIndexPath {
                    tableIncomeView.insertRows(at: [newIndexPath], with: .fade)
                }
            case .delete:
                if let indexPath = indexPath {
                    tableIncomeView.deleteRows(at: [indexPath], with: .fade)
                }
            case .update:
                if let indexPath = indexPath, let cell = tableIncomeView.cellForRow(at: indexPath) as? IncomeCell {
                    let income = fetchedResultsController.object(at: indexPath)
                    cell.configure(with: income)
                }
            case .move:
                if let indexPath = indexPath, let newIndexPath = newIndexPath {
                    tableIncomeView.moveRow(at: indexPath, to: newIndexPath)
                }
            @unknown default:
                fatalError("NSFetchedResultsController change type not handled: \(type)")
            }
        }

        // MARK: - Table View Data Source


        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            guard let sections = fetchedResultsController.sections else { return 0 }
            return sections[section].numberOfObjects
        }

        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncomeCell", for: indexPath) as! IncomeCell
            let income = fetchedResultsController.object(at: indexPath)
            cell.configure(with: income)
            return cell
        }

        override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 90 
        }

        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }

        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                confirmAndDeleteIncome(at: indexPath)
            }
        }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIncome = fetchedResultsController.object(at: indexPath)

        if let navController = storyboard?.instantiateViewController(withIdentifier: "UpdateIncomeNavigationController") as? UINavigationController,
           let updateVC = navController.viewControllers.first as? UpdateIncomeViewController {
            updateVC.incomeToEdit = selectedIncome
            present(navController, animated: true, completion: nil)
        }
    }


    private func confirmAndDeleteIncome(at indexPath: IndexPath) {
        let incomeToDelete = fetchedResultsController.object(at: indexPath)

        let alert = UIAlertController(title: "Eliminar Ingreso", message: "¿Estás seguro de que quieres eliminar este ingreso?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Eliminar", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            let incomeAmount = incomeToDelete.incomeMount
            self.repository.deleteIncome(income: incomeToDelete) { success in
                if success {
                    self.updateTotalAfterDeletingIncome(incomeAmount: incomeAmount)
                } else {
                    // Mostrar un mensaje de error si es necesario
                }
            }
        }
        
        alert.addAction(deleteAction)

        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func updateTotalAfterDeletingIncome(incomeAmount: Double) {
        repository.getTotalByEmail(email: email) { [weak self] totalEntity in
            guard let self = self, let totalEntity = totalEntity else {
                // Manejar el caso de no encontrar el total
                return
            }

            let updatedIncomeTotal = totalEntity.totalIncome - incomeAmount
            let updatedBalance = totalEntity.balanceTotal - incomeAmount

            var totalDetails: [String: Any] = [
                "totalIncome": updatedIncomeTotal,
                "balanceTotal": updatedBalance
            ]

            self.repository.updateTotal(total: totalEntity, totalDetails: totalDetails) { success in
                DispatchQueue.main.async {
                    if !success {
                        print("Error total update income")
                    }
                }
            }
        }
    }
}
