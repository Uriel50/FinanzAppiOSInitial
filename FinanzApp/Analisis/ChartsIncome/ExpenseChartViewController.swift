//
//  ExpenseChartViewController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 07/12/23.
//

import UIKit
import Charts
import CoreData

class ExpenseChartViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var pieExpenseChart: PieChartView!
    
    @IBOutlet weak var ChartExpenseView: UIView!
    
    
    @IBOutlet weak var EmptyView: UIView!
    
    let customColors = [
        UIColor.systemGreen,
        UIColor.systemBlue,
        UIColor.brown,
        UIColor.systemRed,
        UIColor.systemTeal,
        UIColor.systemYellow,
        UIColor.systemGray,
        UIColor.systemCyan,
        UIColor.systemPurple
    ]
    
    
    var fetchedResultsController: NSFetchedResultsController<ExpenseEntity>!
        let repository = FinanzAppRepository()
        let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        let categories = ["Comida", "Transporte", "Vivienda", "Entretenimiento", "Salud", "Educacion", "Impuestos", "Viajes", "Otros"]

        override func viewDidLoad() {
            super.viewDidLoad()
            setupFetchedResultsController()
        }

        private func setupFetchedResultsController() {
            let fetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "userEmailExpense == %@", email)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "expenseCategory", ascending: true)]

            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: repository.context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            fetchedResultsController.delegate = self

            do {
                try fetchedResultsController.performFetch()
                updateChartData()
            } catch {
                print("Error al realizar la operación fetch: \(error)")
            }
        }

    private func updateChartData() {
        var categorySums = [String: Double]()
        if let expenses = fetchedResultsController.fetchedObjects,!expenses.isEmpty {
            for expense in expenses {
                let category = expense.expenseCategory ?? "Otros"
                categorySums[category, default: 0] += expense.expenseMount
            }
            
            
            let entries = categorySums.compactMap { category, sum -> PieChartDataEntry? in
                return categories.contains(category) ? PieChartDataEntry(value: sum, label: category) : nil
            }
            
            let dataSet = PieChartDataSet(entries: entries, label: "")
            dataSet.colors = customColors
            dataSet.valueTextColor = .white
            dataSet.valueFont = UIFont.systemFont(ofSize: 15.0)
            
            let data = PieChartData(dataSet: dataSet)
            pieExpenseChart.data = data
            pieExpenseChart.chartDescription.text = ""
            pieExpenseChart.centerText = "Gastos"
            pieExpenseChart.animate(yAxisDuration: 1.0)
            
            ChartExpenseView.isHidden = false
            EmptyView.isHidden = true
            
        }else{
            ChartExpenseView.isHidden = true
            EmptyView.isHidden = false
        }
    }
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            updateChartData()
        }
    }

    extension ExpenseChartViewController {
        // Añadir aquí extensiones y métodos adicionales si son necesarios
    }
