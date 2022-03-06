//
//  transactionDetailTableViewController.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/3/4.
//

import UIKit

class transactionDetailTableViewController: UITableViewController {

    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var stockSymbolLabel: UILabel!
    
    var stockSymbol : String?
    var company : String?
    var stockRecord :stockTransaction?
    
    
    var transactionRecord = [stockTransaction](){
        didSet{
            stockTransaction.saveTransactionRecord(transactionRecord)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let transactionRecord = stockTransaction.loadTransactionRecord(){
            self.transactionRecord = transactionRecord
        }
        if let stockSymbol = stockSymbol,
           let company = company{
            stockSymbolLabel.text = stockSymbol
            companyLabel.text = company
        }
        
        if let stockRecord = transactionRecord.first(where: {$0.stockSymbol == stockSymbol}) {
            self.stockRecord = stockRecord
        }
    }

    // MARK: - Table view data source

    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (stockRecord?.transactions.count)!
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(TransactionDetailTableViewCell.self)", for: indexPath) as? TransactionDetailTableViewCell else {return UITableViewCell()}
        
        if let stock = stockRecord?.transactions[indexPath.row]{
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
            cell.dateLabel.text = formatter.string(from: stock.tradeDate)
            cell.ActionLabel.text = stock.buyAction
            cell.overrideUserInterfaceStyle = .dark
        }
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
                self.stockRecord?.transactions.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            
            
        }
    }


    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        if let removeItem = stockRecord?.transactions[fromIndexPath.row]{
            stockRecord?.transactions.remove(at: fromIndexPath.row)
            stockRecord?.transactions.insert(removeItem, at: to.row)
        }
    }
    

    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
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
