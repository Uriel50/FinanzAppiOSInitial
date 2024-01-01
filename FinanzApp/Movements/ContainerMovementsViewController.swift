//
//  ContainerMovementsViewController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 15/12/23.
//

import UIKit
import CoreData

class ContainerMovementsViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var containerMovementsView: UIView!
    
    var fetchedResultsController: NSFetchedResultsController<BudgetEntity>!
    let repository = FinanzAppRepository() // Asegúrate de que esto esté correctamente configurado
    let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
    }

    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userEmailBudget == %@", email)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "nameBudget", ascending: true)] // Asegúrate de usar un atributo válido para ordenar

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: repository.context,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
            updateViewBasedOnData()
        } catch {
            print("Error al realizar la operación fetch: \(error)")
        }
    }

    private func updateViewBasedOnData() {
        if let budgets = fetchedResultsController.fetchedObjects, !budgets.isEmpty {
            loadViewController(identifier: "MovementsViewController", isXib: false)
        } else {
            loadViewController(identifier: "EmptyMovementsViewController", isXib: true)
        }
    }

    private func loadViewController(identifier: String, isXib: Bool) {
        // Eliminar el viewController actual del containerView si existe
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }

        let viewController: UIViewController
        if isXib {
            viewController = UIViewController(nibName: identifier, bundle: nil)
        } else {
            viewController = storyboard?.instantiateViewController(withIdentifier: identifier) ?? UIViewController()
        }

        // Agregar el nuevo viewController
        addChild(viewController)
        viewController.view.frame = containerMovementsView.bounds
        containerMovementsView.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }

    // NSFetchedResultsControllerDelegate method
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateViewBasedOnData()
    }
}
