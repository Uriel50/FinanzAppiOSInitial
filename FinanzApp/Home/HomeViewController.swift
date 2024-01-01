//
//  HomeViewController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 14/12/23.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    //Container de Balance
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var cardViewHeightConstraint: NSLayoutConstraint!
    
    //Container de Charts
    
    
    @IBOutlet weak var containerViewCharts: UIView!
    
    
    @IBOutlet weak var cardViewHeighConstraintCharts: NSLayoutConstraint!
    
    
    @IBOutlet weak var containerChartsViewHeightConstraint: NSLayoutConstraint!
    
    
    
    //Container de Reminders
    
    @IBOutlet weak var containerViewReminders: UIView!
    
    @IBOutlet weak var containerRemindersViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cardViewHeightConstraintReminder: NSLayoutConstraint!
    
    

    
    
    
    
    
    
    // Repositorio y email del usuario
        let repository = FinanzAppRepository()
        let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""

        // NSFetchedResultsControllers
        var totalsFetchedResultsController: NSFetchedResultsController<TotalsEntity>?
        var incomesFetchedResultsController: NSFetchedResultsController<IncomeEntity>?
        var expensesFetchedResultsController: NSFetchedResultsController<ExpenseEntity>?
        var remindersFetchedResultsController: NSFetchedResultsController<ReminderEntity>?

        override func viewDidLoad() {
            super.viewDidLoad()
            setupFetchedResultsControllers()
        }
    

        func setupFetchedResultsControllers() {
            setupTotalsFetchedResultsController()
            setupIncomesFetchedResultsController()
            setupExpensesFetchedResultsController()
            setupRemindersFetchedResultsController()
        }

        func setupTotalsFetchedResultsController() {
            let fetchRequest: NSFetchRequest<TotalsEntity> = TotalsEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "userEmailTotal == %@", email)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "balanceTotal", ascending: false)]
            
            totalsFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: repository.context, sectionNameKeyPath: nil, cacheName: nil)
            totalsFetchedResultsController?.delegate = self
            
            do {
                try totalsFetchedResultsController?.performFetch()
                updateBalanceContainerView()
            } catch {
                fatalError("Totals FetchedResultsController failed: \(error)")
            }
        }

        func setupIncomesFetchedResultsController() {
            let fetchRequest: NSFetchRequest<IncomeEntity> = IncomeEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "userEmailIncome == %@", email)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "incomeDate", ascending: false)]
            
            incomesFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: repository.context, sectionNameKeyPath: nil, cacheName: nil)
            incomesFetchedResultsController?.delegate = self
            
            do {
                try incomesFetchedResultsController?.performFetch()
                updateChartsContainerView()
            } catch {
                fatalError("Incomes FetchedResultsController failed: \(error)")
            }
        }

        func setupExpensesFetchedResultsController() {
            let fetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "userEmailExpense == %@", email)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "expenseDate", ascending: false)]
            
            expensesFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: repository.context, sectionNameKeyPath: nil, cacheName: nil)
            expensesFetchedResultsController?.delegate = self
            
            do {
                try expensesFetchedResultsController?.performFetch()
                updateChartsContainerView()
            } catch {
                fatalError("Expenses FetchedResultsController failed: \(error)")
            }
        }

        func setupRemindersFetchedResultsController() {
            let fetchRequest: NSFetchRequest<ReminderEntity> = ReminderEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "userEmailReminder == %@", email)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "reminderDate", ascending: false)]
            
            remindersFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: repository.context, sectionNameKeyPath: nil, cacheName: nil)
            remindersFetchedResultsController?.delegate = self
            
            do {
                try remindersFetchedResultsController?.performFetch()
                updateRemindersContainerView()
            } catch {
                fatalError("Reminders FetchedResultsController failed: \(error)")
            }
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if controller == totalsFetchedResultsController {
                updateBalanceContainerView()
            } else if controller == incomesFetchedResultsController || controller == expensesFetchedResultsController {
                updateChartsContainerView()
            } else if controller == remindersFetchedResultsController {
                updateRemindersContainerView()
            }
        }

        func updateBalanceContainerView() {
            let hasTotals = totalsFetchedResultsController?.fetchedObjects?.isEmpty == false
            let identifier = hasTotals ? "BalanceViewController" : "NewStrategyViewController"
            loadViewController(in: containerView, with: identifier, isXib: false)
            adjustHeightConstraintsForBalance(hasTotals)
        }

        func updateChartsContainerView() {
            let hasIncomes = incomesFetchedResultsController?.fetchedObjects?.isEmpty == false
            let hasExpenses = expensesFetchedResultsController?.fetchedObjects?.isEmpty == false
            
            let shouldShowCharts = hasIncomes && hasExpenses
            let identifier = shouldShowCharts ? "PieChartViewController" : "EmptyChartHomeViewController"
            loadViewController(in: containerViewCharts, with: identifier, isXib: false)
            
            cardViewHeighConstraintCharts.constant = 337
            containerChartsViewHeightConstraint.constant = 287
            
        }

        func updateRemindersContainerView() {
            let hasReminders = remindersFetchedResultsController?.fetchedObjects?.isEmpty == false
            let identifier = hasReminders ? "ReminderHomeTableViewController" : "EmptyReminderViewController"
            loadViewController(in: containerViewReminders, with: identifier, isXib: false)
            adjustHeightConstraintsForReminders(hasReminders)
        }

        func adjustHeightConstraintsForBalance(_ hasTotals: Bool) {
            cardViewHeightConstraint.constant = hasTotals ? 168 : 250
            containerViewHeightConstraint.constant = hasTotals ? 118 : 200
        }

        func adjustHeightConstraintsForReminders(_ hasReminders: Bool) {
            cardViewHeightConstraintReminder.constant = hasReminders ? 168 : 250
            containerRemindersViewHeightConstraint.constant = hasReminders ? 118 : 200
        }
    


        func loadViewController(in containerView: UIView?, with identifier: String, isXib: Bool) {
            for child in children {
                if containerView?.contains(child.view) ?? false {
                    child.willMove(toParent: nil)
                    child.view.removeFromSuperview()
                    child.removeFromParent()
                }
            }

            let viewController: UIViewController
            if isXib {
                viewController = UIViewController(nibName: identifier, bundle: nil)
            } else {
                guard let storyboardVC = storyboard?.instantiateViewController(withIdentifier: identifier) else {
                    print("Error: No se pudo encontrar el ViewController con el identificador \(identifier) en el Storyboard")
                    return
                }
                viewController = storyboardVC
            }

            if let containerView = containerView {
                addChild(viewController)
                viewController.view.frame = containerView.bounds
                containerView.addSubview(viewController.view)
                viewController.didMove(toParent: self)
            }
        }
    }
