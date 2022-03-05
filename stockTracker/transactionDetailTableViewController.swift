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
            cell.amountLabel.text = stock.total.description
            cell.sharesLabel.text = stock.shares.description
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd\nHH:mm"
            cell.dateLabel.text = formatter.string(from: stock.tradeDate)
            if stock.buyAction{
                cell.ActionLabel.text = "BUY"
            }else{
                cell.ActionLabel.text = "SELL"
            }
            
        }
        

        
        return cell
    }
    

    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
