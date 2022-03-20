//
//  transactionDetailTableViewController.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/3/4.
//

import UIKit
import CoreData

class transactionDetailTableViewController: UITableViewController {

    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var stockSymbolLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var averagePriceLabel: UILabel!
    @IBOutlet weak var averageDollarCostLabel: UILabel!
    
    @IBOutlet weak var avgPriceChangeLabel: UILabel!
    
    @IBOutlet weak var earningLabel: UILabel!
    
    @IBOutlet weak var earningChangeLabel: UILabel!
    @IBOutlet weak var marketPriceLabel: UILabel!
    @IBOutlet weak var totalSharesLabel: UILabel!
    
    var fetchSpecificResultController : NSFetchedResultsController<TransactionRecord>!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var container : NSPersistentContainer!
    
    var transactionRecords = [TransactionRecord]()
    var stockSymbol : String?
    var company : String?
    
    var websocket : URLSessionWebSocketTask?
    var currentPrice : Double?
    
    
    
    var stockStatisticsList = [stockStatistics](){
        didSet{
            stockStatistics.saveStockStatistics(stockStatisticsList)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80
        if let stockSymbol = stockSymbol,
           let company = company{
            stockSymbolLabel.text = stockSymbol
            companyLabel.text = company
            
            fetchSpecificStockRecord()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        setSession()
        
        if let stockStatisticsList = stockStatistics.loadStockStatistics(){
            self.stockStatisticsList = stockStatisticsList
        }
        
        if let stockSymbol = stockSymbol {
            if let index = stockStatisticsList.firstIndex(where: {$0.stockSymbol == stockSymbol}){
                let stockStat = stockStatisticsList[index]

                updateUI(stockStat: stockStat)
            }else{
                stockStatisticsList.append(
                    stockStatistics(stockSymbol: stockSymbol, totalQuantity: 0, totalDollarCost: 0, AveragePrice: 0, prevAveragePrice: 0, earning: 0, earningChange: 0)
                )
                getStockStatistics()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        websocket?.cancel()
        print("cancelWebsocket")
    }
    
    
    

    // MARK: - Table view data source
    
    // fetch the data filter by specfic stock symbol
    func fetchSpecificStockRecord(){
        transactionRecords.removeAll()
        
        let request = NSFetchRequest<TransactionRecord>(entityName: "TransactionRecord")
        let sortDescripter = NSSortDescriptor(key: "tradeDate", ascending: false)
        request.sortDescriptors = [sortDescripter]
        let pred = NSPredicate(format: "stockSymbol CONTAINS %@", stockSymbol!)
        request.predicate = pred
        
        let context = appDelegate.persistentContainer.viewContext
        fetchSpecificResultController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchSpecificResultController.delegate = self
        
        do {
            try fetchSpecificResultController.performFetch()
            if let fetchObject = fetchSpecificResultController.fetchedObjects{
                self.transactionRecords = fetchObject
            }
        }catch{
            print("fetch data error in transaction detail\(error)")
        }
    }
    
    func updateUI(stockStat : stockStatistics){
        
        totalCostLabel.text =  stockStat.totalDollarCost.getCurrencyFormat()
        
        totalSharesLabel.textColor = .systemGreen
        totalSharesLabel.text = stockStat.totalQuantity.getSharesFormat()
        
        earningLabel.text = stockStat.earning.getCurrencyFormat()
        averagePriceLabel.text = stockStat.AveragePrice.getCurrencyFormat()
        
        averageDollarCostLabel.text = stockStat.AverageDollarCost.getCurrencyFormat()

        getChangeLabelText(change: stockStat.AveragePriceChange, changePercentage: stockStat.AveragePriceChangePercentage, label: avgPriceChangeLabel)
        
        getEarningChangeLabel(earningChange: stockStat.earningChange )
        
    }
    
    func getEarningChangeLabel(earningChange : Double){
        if earningChange > 0 {
            earningChangeLabel.textColor = .systemGreen
        }else if earningChange == 0{
            earningChangeLabel.textColor = .lightGray
        }else{
            earningChangeLabel.textColor = .systemRed
        }
        earningChangeLabel.text = earningChange.getChangeCurrencyFormat()
    }
    

    func getStockStatistics(){
        print("UpdateStockStat")
        
        // get average price
        let sortedTransactionRecords = transactionRecords.sorted(by: {$0.tradeDate! < $1.tradeDate!})

        var CumShares = 0.0
        var AvgPrice = 0.0
        var prevAvgPrice = 0.0
        var CumEarning = 0.0
        var Earning = 0.0
        for (index, transaction) in sortedTransactionRecords.enumerated(){
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
        
        if let stockSymbol = stockSymbol,
           let index = stockStatisticsList.firstIndex(where: {$0.stockSymbol == stockSymbol}){
            
            // total Shares
            stockStatisticsList[index].totalQuantity = CumShares
            
            // get totalDollarCost
            let totalCost = transactionRecords.reduce(0.0, {return $0 + $1.total})
            stockStatisticsList[index].totalDollarCost = totalCost
            
                        
            // average price
            stockStatisticsList[index].prevAveragePrice = prevAvgPrice
            stockStatisticsList[index].AveragePrice = AvgPrice
            
            // earning
            stockStatisticsList[index].earning = CumEarning
            stockStatisticsList[index].earningChange = Earning
            
            updateUI(stockStat: stockStatisticsList[index])
        }
    }
    
    func getChangeLabelText(change : Double, changePercentage : Double, label : UILabel){
        
        if change > 0 {
            label.textColor = .systemRed
        }else{
            label.textColor = .systemGreen
        }
        label.text = change.getChangeCurrencyFormat() + ", " + changePercentage.getPercentageFormat()
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionRecords.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(TransactionDetailTableViewCell.self)", for: indexPath) as? TransactionDetailTableViewCell else {return UITableViewCell()}
        
        let stock = transactionRecords[indexPath.row]
        cell.priceLabel.text = stock.price.getCurrencyFormat()
        
        if stock.buyAction == "BUY"{
            cell.ActionLabel.textColor = .systemGreen
            cell.sharesLabel.textColor = .systemGreen
        }else{
            cell.ActionLabel.textColor = .systemRed
            cell.sharesLabel.textColor = .systemRed
        }
        cell.amountLabel.text = stock.total.getCurrencyFormat()
        cell.sharesLabel.text = stock.shares.getSharesFormat()
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd\nHH:mm"
        cell.dateLabel.text = formatter.string(from: stock.tradeDate!)
        cell.ActionLabel.text = stock.buyAction
        cell.overrideUserInterfaceStyle = .dark
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editTransaction", sender: nil)
    }
    
    // delete the transaction and add the alert before actually delete it
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertController = UIAlertController(title :"Warning", message: "Are you sure you want to delete this transaction?\nData will be LOST!!!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                let removeItem = self.transactionRecords[indexPath.row]
                
                self.appDelegate.persistentContainer.viewContext.delete(removeItem)
                self.appDelegate.persistentContainer.saveContext()
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }


        // MARK: - Navigation

    // prepare the data that will send to addTransactionViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? addTransactionTableViewController{
            controller.delegate = self
            if segue.identifier == "addSymbolTransaction"{
                controller.stockSymbol = self.stockSymbol
            }else{
                if let row = tableView.indexPathForSelectedRow?.row{
                    controller.getTransaction = transactionRecords[row]
                }
            }
        }
    }
}

extension transactionDetailTableViewController : addTransactionTableViewControllerDelegate{
    func AddTransactionTableViewController(_ controller : addTransactionTableViewController, sendTransaction transaction:TransactionRecord){
        let context = appDelegate.persistentContainer.viewContext
        if let _ = tableView.indexPathForSelectedRow?.row{
            
        }else{
            context.insert(transaction)
        }
        appDelegate.persistentContainer.saveContext()
        tableView.reloadData()
    }

}


// extension for using NSFetchedResultsController
extension transactionDetailTableViewController : NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent( _ controller: NSFetchedResultsController<NSFetchRequestResult>){
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath{
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath,
            let newIndexPath = newIndexPath {
                tableView.moveRow(at: indexPath, to: newIndexPath)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        default:
            tableView.reloadData()
    
        }
        // remember to save the data back to local transactionRecords
        if let fetchobject = controller.fetchedObjects{
            transactionRecords = fetchobject as! [TransactionRecord]
            getStockStatistics()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}

extension transactionDetailTableViewController : URLSessionWebSocketDelegate{
    
    func setSession(){
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        websocket = urlSession.webSocketTask(with: URL(string: "wss://ws.finnhub.io?token=c7occ8iad3idf06mr490")!)
        websocket?.resume()
    }
    
    func ping(){
        websocket?.sendPing(pongReceiveHandler: { error in
            if let error = error {
                print("ping error: \(error)")
            }
        })
    }
    
    func close(){
        websocket?.cancel(with: .goingAway, reason: "go to next view".data(using: .utf8))
        
    }
    
    func send(){
        if let stockSymbol = stockSymbol{
            
            let string = "{\"type\":\"subscribe\",\"symbol\":\"\(stockSymbol)\"}"
            
            let message = URLSessionWebSocketTask.Message.string(string)
            
            
            
            self.websocket?.send(message, completionHandler: { error in
                if let error = error{
                    print("send error : \(error)")
                }
            })
            
        }
    }
    
    func receive(){
        websocket?.receive(completionHandler: {[weak self] result in
            switch result{
            case .success(let message):
                switch message{
                case .data(let data):
                    print("got data \(data)")
                    
                case .string(let message):
                    do {
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(websocketStockInfo.self, from: Data(message.utf8))
                        DispatchQueue.main.async {
                            self?.marketPriceLabel.text = "$" + result.data[0].p.description
                                                    }
                    }catch{
                       print(error)
                    }
                    
                default:
                    break
                }
                
            case .failure(let error):
                print("receive error : \(error)")
            
            }
            self?.receive()
        })
        
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("did connect to websocket")
        ping()
        receive()
        send()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("close connection")
    }
}





