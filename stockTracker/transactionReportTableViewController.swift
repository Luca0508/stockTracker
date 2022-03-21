//
//  transactionReportTableViewController.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/3/4.
//

import UIKit
import CoreData
import Charts


class transactionReportTableViewController: UITableViewController {
    var container : NSPersistentContainer!
    var fetchedResultController : NSFetchedResultsController<TransactionRecord>!
   
    var transactionRecords = [TransactionRecord]()
    var transaction : TransactionRecord?
    var company : String?
    var symbolList = Array<String>()
    var stockInfoList = stockFullName.data
    
    var changeStockSymbol : String?
    
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    var stockStatisticsList = [stockStatistics](){
        didSet{
            stockStatistics.saveStockStatistics(stockStatisticsList)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 70
//        resetAllRecords(in: "TransactionRecord")
        fetchData()
                

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let stockStatisticsList = stockStatistics.loadStockStatistics(){
            self.stockStatisticsList = stockStatisticsList
        }
        setPieChartView()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    func fetchData(){
        transactionRecords.removeAll()
        
        let request = NSFetchRequest<TransactionRecord>(entityName: "TransactionRecord")
        let sortDescripter = NSSortDescriptor(key: "tradeDate", ascending: false)
        request.sortDescriptors = [sortDescripter]
        
        let context = container.viewContext
        fetchedResultController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        
        do{
            try fetchedResultController.performFetch()
            if let fetchObject = fetchedResultController.fetchedObjects{
                self.transactionRecords = fetchObject
                groupby()
            }
                        
        }catch{
            print("fetch data error in transactionReport : \(error)")
        }
    }
    
    // get the unique stock symbol
    func groupby(){
        let groupbyDictionary = Dictionary(grouping: transactionRecords, by:{ $0.stockSymbol})
        symbolList.removeAll()
        for s in groupbyDictionary.keys{
            symbolList.append(s!)
        }
    }
    
    func getEarning(stockSymbol : String) -> Double{
        
        if let index = stockStatisticsList.firstIndex(where: {$0.stockSymbol == stockSymbol}){
            return stockStatisticsList[index].earning
        }
        return 0
    }
    
    
    func setPieChartView(){
        let pieChartDataEntries = symbolList.map({(symbol) -> PieChartDataEntry in
            return PieChartDataEntry(value: getEarning(stockSymbol: symbol), label:symbol)
        })
        
        let pieChartDataSet = PieChartDataSet(entries: pieChartDataEntries, label: "")
        pieChartDataSet.selectionShift = 10
        pieChartDataSet.sliceSpace = 2
        
        pieChartDataSet.colors = ChartColorTemplates.pastel() + ChartColorTemplates.material()

        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        
        pieChartData.setValueFormatter(percentageValueFormatter())
        pieChartData.setValueFont(.systemFont(ofSize: 12, weight: .regular))
        pieChartData.setValueTextColor(.white)
        
        class percentageValueFormatter : NSObject,ValueFormatter{
            func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
                return String(format: "%.1f%%", value)
            }
        }
        
        pieChartView.data = pieChartData
        pieChartView.usePercentValuesEnabled = true
        pieChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        pieChartView.sliceTextDrawingThreshold = 20
                
        let legend = pieChartView.legend
        legend.horizontalAlignment = .center
        legend.verticalAlignment = .bottom
        legend.orientation = .horizontal
        legend.textColor = .white
        legend.font = UIFont.systemFont(ofSize: 12)
        legend.form = .circle
        legend.formToTextSpace = 4
        legend.formSize = 10
                       
        let totalEarning = stockStatisticsList.reduce(0.0, {$0 + $1.earning})
        pieChartView.centerText = "Total Earning :\n \(totalEarning.getCurrencyFormat())"
    }
    
        
    // entity = Your_Entity_Name
    func resetAllRecords(in entity : String){
        let context = ( UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do{
            try context.execute(deleteRequest)
            try context.save()
        }catch{
            print ("There was an error")
        }
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  symbolList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(transactionReportTableViewCell.self)", for: indexPath) as? transactionReportTableViewCell else {return UITableViewCell()}
        

        cell.stockSymbolLabel.text = symbolList[indexPath.row]
        
        if let index = stockStatisticsList.firstIndex(where: {$0.stockSymbol == symbolList[indexPath.row]}){
            let stockStat = stockStatisticsList[index]
            cell.sharesLabel.text = stockStat.totalQuantity.getSharesFormat()
            cell.avgPriceLabel.text = stockStat.AveragePrice.getCurrencyFormat()
            cell.earningLabel.text =   stockStat.earning.getCurrencyFormat()
            cell.moneyBalanceLabel.text = stockStat.totalDollarCost.getCurrencyFormat()
        }
        
        cell.overrideUserInterfaceStyle = .dark
        return cell
    }
    
    func getComanyName (stockSymbol : String) -> String{
        if let index = stockInfoList.firstIndex(where: {$0.Symbol == stockSymbol}){
            return stockInfoList[index].CompanyName
        }else{
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "showStockDetail", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? transactionDetailTableViewController,
         let row = tableView.indexPathForSelectedRow?.row{

            let symbol = symbolList[row]
            controller.stockSymbol = symbol
            controller.company = getComanyName(stockSymbol: symbol)
        }
        
        if let addController = segue.destination as? addTransactionTableViewController{
            addController.delegate = self
        }
    }
    
    // remove the delete option while editing
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return.none
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        container.viewContext.delete(self.fetchedResultController.object(at: indexPath))
        container.saveContext()

    }
    
    func updateStockStatistics(changeStockSymbol : String){
        
        // filter and sort
        let changeStockTransactionRecords = transactionRecords.filter({$0.stockSymbol == changeStockSymbol}).sorted(by: {$0.tradeDate! < $1.tradeDate!})
        
        // get average price
        var CumShares = 0.0
        var AvgPrice = 0.0
        var prevAvgPrice = 0.0
        var CumEarning = 0.0
        var Earning = 0.0
        for (index, transaction) in changeStockTransactionRecords.enumerated(){
            if index == 0{
                AvgPrice = transaction.price
                CumShares = transaction.shares
                Earning = 0.0
            }else if transaction.buyAction == "BUY"{
                let newCumShares = CumShares + transaction.shares
                prevAvgPrice = AvgPrice
                AvgPrice = (AvgPrice * CumShares + transaction.price * transaction.shares) / newCumShares
                CumShares = newCumShares
                Earning = 0.0
            }else if transaction.buyAction == "SELL"{
                CumShares += transaction.shares
                Earning = (transaction.price - AvgPrice) * abs(transaction.shares)
                CumEarning += Earning
            }
        }
        
        if let index = stockStatisticsList.firstIndex(where: {$0.stockSymbol == changeStockSymbol}){
            
            // total Shares
            stockStatisticsList[index].totalQuantity = CumShares
            
            // get totalDollarCost
            let totalCost = changeStockTransactionRecords.reduce(0.0, {return $0 + $1.total})
            stockStatisticsList[index].totalDollarCost = totalCost
                   
            // average price
            stockStatisticsList[index].prevAveragePrice = prevAvgPrice
            stockStatisticsList[index].AveragePrice = AvgPrice
            
            // earning
            stockStatisticsList[index].earning = CumEarning
            stockStatisticsList[index].earningChange = Earning
        }
    }
}
extension transactionReportTableViewController : addTransactionTableViewControllerDelegate{
    func AddTransactionTableViewController(_ controller : addTransactionTableViewController, sendTransaction transaction : TransactionRecord){
        
        changeStockSymbol = transaction.stockSymbol
        
        let context = container.viewContext
        context.insert(transaction)
        container.saveContext()
        
        if !stockStatisticsList.contains(where: {$0.stockSymbol == changeStockSymbol}),
           let changeStockSymbol = changeStockSymbol{
            stockStatisticsList.append(
                stockStatistics(stockSymbol: changeStockSymbol, totalQuantity: 0, totalDollarCost: 0, AveragePrice: 0, prevAveragePrice: 0, earning: 0, earningChange: 0)
            )
        }
        updateStockStatistics(changeStockSymbol: changeStockSymbol!)
        
        tableView.reloadData()
    }
}

extension transactionReportTableViewController : NSFetchedResultsControllerDelegate{

//    func controllerWillChangeContent( _ controller: NSFetchedResultsController<NSFetchRequestResult>){
//        tableView.beginUpdates()
//    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            if let newIndexPath = newIndexPath{
//                tableView.insertRows(at: [newIndexPath], with: .automatic)
//            }
//        case .delete:
//            if let indexPath = indexPath {
//                tableView.deleteRows(at: [indexPath], with: .automatic)
//            }
//        case .move:
//            if let indexPath = indexPath,
//            let newIndexPath = newIndexPath {
//                tableView.moveRow(at: indexPath, to: newIndexPath)
//            }
//        case .update:
//            if let indexPath = indexPath {
//                tableView.reloadRows(at: [indexPath], with: .automatic)
//            }
//        default:
//            tableView.reloadData()
//
//        }
        if let fetchobject = controller.fetchedObjects{
            transactionRecords = fetchobject as! [TransactionRecord]
            groupby()
            
            
            tableView.reloadData()


        }

    }
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
//    }
}



