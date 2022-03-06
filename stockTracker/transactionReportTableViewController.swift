//
//  transactionReportTableViewController.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/3/4.
//

import UIKit


class transactionReportTableViewController: UITableViewController {
   
    
    var transactionRecord = [stockTransaction](){
        didSet{
            stockTransaction.saveTransactionRecord(transactionRecord)
        }
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 70
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let transactionRecord = stockTransaction.loadTransactionRecord(){
            self.transactionRecord = transactionRecord
        }
        
    }

    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return  transactionRecord.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(transactionReportTableViewCell.self)", for: indexPath) as? transactionReportTableViewCell else {return UITableViewCell()}
        let stock = transactionRecord[indexPath.row]

        cell.stockSymbolLabel.text = stock.stockSymbol
        cell.companyLabel.text = stock.company
        
        cell.overrideUserInterfaceStyle = .dark

        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "showStockDetail", sender: nil)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as? transactionDetailTableViewController
        if let row = tableView.indexPathForSelectedRow?.row{
            let stock = transactionRecord[row]
            controller?.stockSymbol = stock.stockSymbol
            controller?.company = stock.company
        }
    }
    
    
    @IBAction func clickEditButton(_ sender: UIBarButtonItem) {
        super.setEditing(!tableView.isEditing, animated: true)
        sender.title = tableView.isEditing ? "Done" : "Edit"
        tableView.allowsSelectionDuringEditing = true
        tableView.reloadData()
        
    }
    
    // remove the delete option while editing
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return.none
    }
    
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let removeItem = transactionRecord[fromIndexPath.row]
        transactionRecord.remove(at: fromIndexPath.row)
        transactionRecord.insert(removeItem, at: to.row)
        tableView.reloadData()

    }
    

    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//extension transactionReportTableViewController : addTransactionTableViewControllerDelegate{
//    func addTransactionTableViewController(_ controller : addTransactionTableViewController, addTransaction :[stockTransaction]){
//        
//    }
//}
