//
//  IncomeChartViewController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 07/12/23.
//

import UIKit
import Charts
import CoreData

class IncomeChartViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var pieChartIncome: PieChartView!
    
    @IBOutlet var ChartView: UIView!
    
    @IBOutlet var EmptyChartView: UIView!
    
    let customColors = [
        UIColor.systemBlue,
        UIColor.systemGreen,
        UIColor.systemOrange,
        UIColor.systemGray,
        UIColor.systemYellow,
        UIColor.systemPurple
    ]
    
    
    var fetchedResultsController: NSFetchedResultsController<IncomeEntity>!
        let repository = FinanzAppRepository() // Asegúrate de que esto esté correctamente configurado
        let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        let categories = ["Salario", "Inversiones", "Aquileres", "Pension", "Regalias", "Otros"]

        override func viewDidLoad() {
            super.viewDidLoad()
            setupFetchedResultsController()
        }

        private func setupFetchedResultsController() {
            let fetchRequest: NSFetchRequest<IncomeEntity> = IncomeEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "userEmailIncome == %@", email)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "incomeCategory", ascending: true)]

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
        if let incomes = fetchedResultsController.fetchedObjects, !incomes.isEmpty {
            // Hay datos, procesar y mostrar el gráfico
            for income in incomes {
                let category = income.incomeCategory ?? "Otros"
                categorySums[category, default: 0] += income.incomeMount
            }

            let entries = categorySums.compactMap { category, sum -> PieChartDataEntry? in
                return categories.contains(category) ? PieChartDataEntry(value: sum, label: category) : nil
            }

            let dataSet = PieChartDataSet(entries: entries, label: "")
            dataSet.colors = customColors
            dataSet.valueTextColor = .white
            dataSet.valueFont = UIFont.systemFont(ofSize: 15.0)

            let data = PieChartData(dataSet: dataSet)
            pieChartIncome.data = data
            pieChartIncome.chartDescription.text = ""
            pieChartIncome.centerText = "Ingresos"
            pieChartIncome.animate(yAxisDuration: 1.0)

            // Mostrar ChartView y ocultar EmptyChartView
            ChartView.isHidden = false
            EmptyChartView.isHidden = true
        } else {
            // No hay datos, mostrar EmptyChartView y ocultar ChartView
            ChartView.isHidden = true
            EmptyChartView.isHidden = false
        }
    }


        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            updateChartData()
        }
    }

    extension IncomeChartViewController {
        // Añadir aquí extensiones y métodos adicionales si son necesarios
    }
