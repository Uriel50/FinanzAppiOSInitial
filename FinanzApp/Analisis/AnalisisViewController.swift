//
//  BarChartAnalisis.swift
//  FinanzApp
//
//  Created by Uriel Candia on 05/12/23.
//

import UIKit
import Charts
import CoreData

class AnalisisViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var chart: BarChartView!
    
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    //BarCharLineIncome
    
    @IBOutlet weak var ProgressViewIncome: UIProgressView!
    
    @IBOutlet weak var mountIncome: UILabel!
    
    @IBOutlet weak var percentIncome: UILabel!
    
    //BarCharLineExpense
    
    
    @IBOutlet weak var ProgressViewExpense: UIProgressView!
    
    @IBOutlet weak var mountExpense: UILabel!
    
    @IBOutlet weak var percentExpense: UILabel!
    
    let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
    var fetchedResultsController: NSFetchedResultsController<TotalsEntity>!
    let repository = FinanzAppRepository()

    
    
    
    private var options : [String] = ["Ingresos", "Gastos"]
    var currentPageIndex : Int = 0
    
    
    var rootPageViewController :  ChartInExViewController!
    
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        
        currentPageIndex = sender.selectedSegmentIndex
        let direction: UIPageViewController.NavigationDirection = currentPageIndex == 0 ? .reverse : .forward
        rootPageViewController.setViewControllersFromIndex(index: currentPageIndex, direction: direction, animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupChartBar()
        loadChartBarData()
        setupFetchedResultsController()
        setupSegmentControl()
    }
    
    func setupSegmentControl() {
        segmentControl.removeAllSegments()
        for (index, option) in options.enumerated() {
            segmentControl.insertSegment(withTitle: option, at: index, animated: false)
        }
        segmentControl.selectedSegmentIndex = 0
        
        
        // Establece el color del texto cuando la opción está seleccionada
        let titleTextAttributesSelected = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentControl.setTitleTextAttributes(titleTextAttributesSelected, for: .selected)

        // Establece el color del texto cuando la opción no está seleccionada
        let titleTextAttributesNormal = [NSAttributedString.Key.foregroundColor: UIColor.black]
        segmentControl.setTitleTextAttributes(titleTextAttributesNormal, for: .normal)
    }
    
    

    func setupChartBar() {
        if let chart = chart {
            chart.chartDescription.enabled = false
            chart.pinchZoomEnabled = false
            chart.drawBarShadowEnabled = false
            chart.drawGridBackgroundEnabled = false

            let legend = chart.legend
            legend.enabled = false
            
            

            let xAxis = chart.xAxis
            xAxis.granularity = 1.0
            xAxis.labelPosition = .bottom
            xAxis.centerAxisLabelsEnabled = true
            // ... Configure other xAxis properties ...
            // Configura las etiquetas del eje X con los nombres de los meses
            xAxis.valueFormatter = IndexAxisValueFormatter(values: ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio"])
            xAxis.labelCount = 6 // El número de etiquetas que deseas mostrar en el eje X
            xAxis.axisMinimum = 0
            xAxis.axisMaximum = 6


            let leftAxis = chart.leftAxis
            leftAxis.drawGridLinesEnabled = false
            leftAxis.axisMinimum = 0




            chart.rightAxis.enabled = false
        } else {
            // Manejar el caso en el que chart es nil
            print("Error: El objeto chart es nil.")
        }

        
    }

    func loadChartBarData() {
        
        if let chart = chart {

            let months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio"]
            var values1: [BarChartDataEntry] = []
            var values2: [BarChartDataEntry] = []

            for i in 0..<months.count {
                values1.append(BarChartDataEntry(x: Double(i), y: Double.random(in: 0.0...10.0)))
                values2.append(BarChartDataEntry(x: Double(i), y: Double.random(in: 0.0...10.0)))
            }

            let set1 = BarChartDataSet(entries: values1, label: "Income")
            set1.colors = [NSUIColor.systemBlue]

            let set2 = BarChartDataSet(entries: values2, label: "Expense")
            set2.colors = [NSUIColor.systemRed]

            let data = BarChartData(dataSets: [set1, set2])
            let groupSpace = 0.2
            let barSpace = 0.05
            let barWidth = (1.0 - groupSpace) / 2.0 - barSpace
            data.barWidth = barWidth

            chart.data = data
            chart.groupBars(fromX: 0.0, groupSpace: groupSpace, barSpace: barSpace)
            chart.notifyDataSetChanged()
        } else {
            // Manejar el caso en el que chart es nil
            print("Error: El objeto chart es nil.")
        }
        
    }
    
    private func setupFetchedResultsController() {
            let fetchRequest: NSFetchRequest<TotalsEntity> = TotalsEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "userEmailTotal == %@", email)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "userEmailTotal", ascending: true)]

            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: repository.context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            fetchedResultsController.delegate = self

            do {
                try fetchedResultsController.performFetch()
                if let totals = fetchedResultsController.fetchedObjects?.first {
                    updateUIWithTotalData(totals)
                }
            } catch {
                print("Error al realizar la operación fetch: \(error)")
            }
        }

        private func updateUIWithTotalData(_ totalEntity: TotalsEntity) {
            // Actualiza la UI con los datos de totalEntity
            let income = max(totalEntity.totalIncome, 0)
            let expense = max(totalEntity.totalExpense, 0)

            updateBarCharLineViews(income: income, expense: expense, total: totalEntity.balanceTotal)
            loadChartBarData()
        }
    private func updateBarCharLineViews(income: Double, expense: Double, total: Double) {
        // Calcular el total y los porcentajes
    
        let incomePercentage = total > 0 ? income / total : 0
        let expensePercentage = total > 0 ? expense / total : 0

        // Configurar las barras de progreso
        ProgressViewIncome.setProgress(Float(incomePercentage), animated: true)
        ProgressViewExpense.setProgress(Float(expensePercentage), animated: true)

        // Configurar las etiquetas
        mountIncome.text = String(format: "$%.2f", income)
        mountExpense.text = String(format: "$%.2f", expense)

        percentIncome.text = String(format: "%.0f%% de $%.2f previstos", incomePercentage * 100, total)
        percentExpense.text = String(format: "%.0f%% de $%.2f previstos", expensePercentage * 100, total)
    }

        // NSFetchedResultsControllerDelegate methods
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let totals = fetchedResultsController.fetchedObjects?.first {
            updateUIWithTotalData(totals)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ChartInExViewController {
            destination.delegateRoot = self
            rootPageViewController = destination
        }
    }
}

extension AnalisisViewController: RootPageProtocol{
    
    
    func currentPage(_ index: Int) {
       currentPageIndex = index
       segmentControl.selectedSegmentIndex = index
   }
    
    func scrollDetails(direction: ScrollDirection, percent: CGFloat, index: Int) {
    
    }
}

