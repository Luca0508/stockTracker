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
    
    
    var stockSymbol : String?
    var company : String?
    
    var container : NSPersistentContainer!
    var specificStockRecord = [StockRecord]()
    var transactionRecord = [TransactionRecord]()
    
//    var stockRecord :stockTransaction?
//
//
//    var transactionRecord = [stockTransaction](){
//        didSet{
//            stockTransaction.saveTransactionRecord(transactionRecord)
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if let transactionRecord = stockTransaction.loadTransactionRecord(){
//            self.transactionRecord = transactionRecord
//        }
        
        
//        if let stockRecord = transactionRecord.first(where: {$0.stockSymbol == stockSymbol}) {
//            self.stockRecord = stockRecord
//        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let stockSymbol = stockSymbol,
           let company = company{
            stockSymbolLabel.text = stockSymbol
            companyLabel.text = company
            
            fetchSpecificStockRecord()
        }
        
    }

    // MARK: - Table view data source
    
    func fetchSpecificStockRecord(){
        do{
            let request = StockRecord.fetchRequest()
            let pred = NSPredicate(format: "stockSymbol CONTAINS %@", stockSymbol!)
            request.predicate = pred
            specificStockRecord = try container.viewContext.fetch(request)
            if specificStockRecord.count == 1{
                transactionRecord = specificStockRecord[0].transactionInfo?.allObjects as! [TransactionRecord]
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }catch{
            print(error)
        }
    }

    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return transactionRecord.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(TransactionDetailTableViewCell.self)", for: indexPath) as? TransactionDetailTableViewCell else {return UITableViewCell()}
        
        let stock = transactionRecord[indexPath.row]
        cell.priceLabel.text = stock.price.description
        if stock.buyAction == "BUY"{
            cell.amountLabel.text = "-" + stock.total.description
            cell.sharesLabel.text = "+" + stock.shares.description
        }else{
            cell.amountLabel.text = "+" + stock.total.description
            cell.sharesLabel.text = "-" + stock.shares.description
        }
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd\nHH:mm"
        cell.dateLabel.text = formatter.string(from: stock.tradeDate!)
        cell.ActionLabel.text = stock.buyAction
        cell.overrideUserInterfaceStyle = .dark
        
        return cell
    }
    

    
    @IBAction func clickEditButton(_ sender: UIButton) {
        super.setEditing(!tableView.isEditing, animated: true)
        let title = tableView.isEditing ? "Done" : "Edit"
        sender.setTitle(title, for: .normal)
        tableView.allowsSelectionDuringEditing = true
        tableView.reloadData()
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

   
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertController = UIAlertController(title :"Warning", message: "Are you sure you want to delete this transaction?\nData will be LOST!!!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                let removeItem = self.transactionRecord[indexPath.row]
                let removeTransaction = TransactionRecord(context: self.container.viewContext)
                removeTransaction.tradeDate = removeItem.tradeDate
                removeTransaction.price = removeItem.price
                removeTransaction.shares = removeItem.shares
                removeTransaction.buyAction = removeItem.buyAction
                removeTransaction.total = removeItem.total
                
                
                self.specificStockRecord[0].removeFromTransactionInfo(removeTransaction)
                
                self.container.saveContext()
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }


    
    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        stockRecord?.transactions.remove(at: indexPath.row)
//        tableView.deleteRows(at: [indexPath], with: .automatic)
//        tableView.reloadData()
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
