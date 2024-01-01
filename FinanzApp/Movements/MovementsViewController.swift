//
//  MovementsViewController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 08/12/23.
//

import UIKit
import CoreData

class MovementsViewController: UIViewController, NSFetchedResultsControllerDelegate, RootPageProtocol {

    @IBOutlet weak var tabMovements: TabsViewMovements!
    
    @IBOutlet weak var titleBudget: UILabel!
    
    @IBOutlet weak var mountBalanceTotal: UILabel!
    
    @IBOutlet weak var segmentedControlMovements: UISegmentedControl!
    
    let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
    let repository = FinanzAppRepository()
    var fetchedResultsControllerBudget: NSFetchedResultsController<BudgetEntity>!
    var fetchedResultsControllerTotals: NSFetchedResultsController<TotalsEntity>!
    
    var rootPageControllerMov: MovInExViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedControl()
        initializeFetchedResultsController()
    }
    
    private func setupSegmentedControl() {
        segmentedControlMovements.removeAllSegments()
        segmentedControlMovements.insertSegment(withTitle: "Ingresos", at: 0, animated: false)
        segmentedControlMovements.insertSegment(withTitle: "Gastos", at: 1, animated: false)
        segmentedControlMovements.selectedSegmentIndex = 0
        
        let titleTextAttributesSelected = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentedControlMovements.setTitleTextAttributes(titleTextAttributesSelected, for: .selected)
        
        let titleTextAttributesNormal = [NSAttributedString.Key.foregroundColor: UIColor.black]
        segmentedControlMovements.setTitleTextAttributes(titleTextAttributesNormal, for: .normal)
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let direction: UIPageViewController.NavigationDirection = sender.selectedSegmentIndex == 0 ? .forward : .reverse
        rootPageControllerMov.setViewControllersFromIndexMov(index: sender.selectedSegmentIndex, direction: direction, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MovInExViewController {
            destination.delegateRoot = self
            rootPageControllerMov = destination
        }
    }
    
    private func initializeFetchedResultsController() {
        // Inicializar NSFetchedResultsController para BudgetEntity
        let fetchRequestBudget: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()
        fetchRequestBudget.predicate = NSPredicate(format: "userEmailBudget == %@", email)
        fetchRequestBudget.sortDescriptors = [NSSortDescriptor(key: "nameBudget", ascending: true)]
        fetchedResultsControllerBudget = NSFetchedResultsController(fetchRequest: fetchRequestBudget, managedObjectContext: repository.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsControllerBudget.delegate = self

        // Inicializar NSFetchedResultsController para TotalsEntity
        let fetchRequestTotals: NSFetchRequest<TotalsEntity> = TotalsEntity.fetchRequest()
        fetchRequestTotals.predicate = NSPredicate(format: "userEmailTotal == %@", email)
        fetchRequestTotals.sortDescriptors = [NSSortDescriptor(key: "idTotal", ascending: true)]
        fetchedResultsControllerTotals = NSFetchedResultsController(fetchRequest: fetchRequestTotals, managedObjectContext: repository.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsControllerTotals.delegate = self

        do {
            try fetchedResultsControllerBudget.performFetch()
            try fetchedResultsControllerTotals.performFetch()
            updateUI()
        } catch {
            print("Error al realizar la operación fetch: \(error)")
        }
    }

    private func updateUI() {
        // Actualizar el nombre del presupuesto (Budget)
        if let budget = fetchedResultsControllerBudget.fetchedObjects?.first {
            titleBudget.text = budget.nameBudget
        }

        // Actualizar el total del balance (Totals)
        if let total = fetchedResultsControllerTotals.fetchedObjects?.first {
            mountBalanceTotal.text = "$\(total.balanceTotal)"
        }
    }
    
    // NSFetchedResultsControllerDelegate Methods
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateUI()
    }
}

extension MovementsViewController : RootPageProtocolMovements{
    func currentPage(_ index: Int) {
        segmentedControlMovements.selectedSegmentIndex = index
    }
    
    func scrollDetails(direction: ScrollDirection, percent: CGFloat, index: Int) {
        //func
    }
}
