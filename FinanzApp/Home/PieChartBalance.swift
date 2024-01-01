//
//  PieChartBalance.swift
//  FinanzApp
//
//  Created by Uriel Candia on 06/12/23.
//

import UIKit
import Charts
import CoreData

class PieChartViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var pieChartView: PieChartView!

    let repository = FinanzAppRepository()
    let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
    var fetchedResultsController: NSFetchedResultsController<TotalsEntity>!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
    }

    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TotalsEntity> = TotalsEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userEmailTotal == %@", email)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "userEmailTotal", ascending: true)]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: repository.context,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
            updatePieChart()
        } catch {
            print("Error al realizar la operación fetch: \(error)")
        }
    }

    private func updatePieChart() {
        if let totalEntity = fetchedResultsController.fetchedObjects?.first,
           totalEntity.totalIncome > 0 || totalEntity.totalExpense > 0 {
            setupPieChart(withIncome: totalEntity.totalIncome, andExpense: totalEntity.totalExpense)
        } else {
            pieChartView.data = nil
            pieChartView.noDataText = "No hay datos disponibles."
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updatePieChart()
    }

    private func setupPieChart(withIncome income: Double, andExpense expense: Double) {
        let entries: [ChartDataEntry] = [
            PieChartDataEntry(value: income, label: "Ingresos"),
            PieChartDataEntry(value: expense, label: "Gastos")
        ]

        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.colors = [NSUIColor.init(red: 0, green: 0, blue: 255, alpha: 1), NSUIColor.init(red: 255, green: 0, blue: 0, alpha: 1)]
        dataSet.valueTextColor = .white
        dataSet.valueFont = UIFont.systemFont(ofSize: 15.0)

        let data = PieChartData(dataSet: dataSet)
        pieChartView.data = data
        pieChartView.chartDescription.text = ""
        pieChartView.centerText = "Gastos e Ingresos"
        pieChartView.animate(yAxisDuration: 1.0)
    }
}
