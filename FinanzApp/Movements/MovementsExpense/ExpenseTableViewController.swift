//
//  ExpenseTableViewController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 16/12/23.
//

import UIKit
import CoreData

class ExpenseTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    
    @IBOutlet var expenseTableView: UITableView!
    
    
    @IBOutlet var emptyExpenseView: UIView!
    
    
    let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
    let repository = FinanzAppRepository()
var fetchedResultsController: NSFetchedResultsController<ExpenseEntity>!

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
        let fetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userEmailExpense == %@", email)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "expenseDate", ascending: true)]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: repository.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
            updateView()
        } catch {
            fatalError("ExpenseTableViewController: No se pudo realizar la operación fetch: \(error)")
        }
    }

    private func updateView() {
        DispatchQueue.main.async {
            let hasExpenses = self.fetchedResultsController.fetchedObjects?.count ?? 0 > 0
            self.expenseTableView.backgroundView = hasExpenses ? nil : self.emptyExpenseView
            self.expenseTableView.separatorStyle = hasExpenses ? .singleLine : .none
        }
    }


    // MARK: - NSFetchedResultsControllerDelegate Methods

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateView()
        expenseTableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        expenseTableView.endUpdates()

    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                expenseTableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                expenseTableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath, let cell = expenseTableView.cellForRow(at: indexPath) as? ExpenseCell {
                let expense = fetchedResultsController.object(at: indexPath)
                cell.configure(with: expense)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                expenseTableView.moveRow(at: indexPath, to: newIndexPath)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath) as! ExpenseCell
        let expense = fetchedResultsController.object(at: indexPath)
        cell.configure(with: expense)
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
            confirmAndDeleteExpense(at: indexPath)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedExpense = fetchedResultsController.object(at: indexPath)

        if let navController = storyboard?.instantiateViewController(withIdentifier: "UpdateExpenseNavigationController") as? UINavigationController,
           let updateVC = navController.viewControllers.first as? UpdateExpenseViewController {
            updateVC.expenseToEdit = selectedExpense
            present(navController, animated: true, completion: nil)
        }
    }




    private func confirmAndDeleteExpense(at indexPath: IndexPath) {
        let expenseToDelete = fetchedResultsController.object(at: indexPath)

        let alert = UIAlertController(title: "Eliminar Gasto", message: "¿Estás seguro de que quieres eliminar este gasto?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Eliminar", style: .destructive) { [weak self] _ in
            
            guard let self = self else { return }
            let expenseAmount = expenseToDelete.expenseMount
            self.repository.deleteExpense(expense: expenseToDelete) { success in
                if success {
                    self.updateTotalAfterDeletingExpense(expenseAmount: expenseAmount)
                }else{
                    // Mostrar un mensaje de error si es necesario
                }
            }
        }
        alert.addAction(deleteAction)

        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
    
    func updateTotalAfterDeletingExpense(expenseAmount: Double){
        repository.getTotalByEmail(email: email){ [weak self]
        totalEntity in
            guard let self = self, let totalEntity = totalEntity else{
                return
            }
            let updatedExpenseTotal = totalEntity.totalExpense - expenseAmount
            let updatedBalance = totalEntity.balanceTotal + expenseAmount
            
            var totalDetails: [String: Any] = [
                "totalExpense": updatedExpenseTotal,
                "balanceTotal": updatedBalance
            ]
            
            self.repository.updateTotal(total: totalEntity, totalDetails: totalDetails){ success in
                DispatchQueue.main.async {
                    if !success {
                        print("Error total update expense")
                    }
                }
            }
            
        }
    }


    
    
}
