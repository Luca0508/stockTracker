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
    
    var fetchSpecificResultController : NSFetchedResultsController<TransactionRecord>!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var container : NSPersistentContainer!
    
    var transactionRecords = [TransactionRecord]()
    var stockSymbol : String?
    var company : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let stockSymbol = stockSymbol,
           let company = company{
            stockSymbolLabel.text = stockSymbol
            companyLabel.text = company
            fetchSpecificStockRecord()
        }
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
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionRecords.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(TransactionDetailTableViewCell.self)", for: indexPath) as? TransactionDetailTableViewCell else {return UITableViewCell()}
        
        let stock = transactionRecords[indexPath.row]
        cell.priceLabel.text = stock.price.description
        if stock.buyAction == "BUY"{
            cell.ActionLabel.textColor = .systemGreen
            cell.sharesLabel.textColor = .systemGreen
            cell.amountLabel.text = "-" + stock.total.description
            cell.sharesLabel.text = "+" + stock.shares.description
        }else{
            cell.ActionLabel.textColor = .systemRed
            cell.sharesLabel.textColor = .systemRed
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
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}



