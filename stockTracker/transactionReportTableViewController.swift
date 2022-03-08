//
//  transactionReportTableViewController.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/3/4.
//

import UIKit
import CoreData


class transactionReportTableViewController: UITableViewController {
    var container : NSPersistentContainer!
   
    var stockRecords = [StockRecord]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 70
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if let transactionRecord = stockTransaction.loadTransactionRecord(){
//            self.transactionRecord = transactionRecord
//        }
        fetchStockRecords()
    }

    // MARK: - Table view data source
    func fetchStockRecords(){
        do{
            self.stockRecords = try container.viewContext.fetch(StockRecord.fetchRequest())
            print("fetch data in Report")

        }catch{
            print(error)
        }
                
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return  stockRecords.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(transactionReportTableViewCell.self)", for: indexPath) as? transactionReportTableViewCell else {return UITableViewCell()}
        let stock = stockRecords[indexPath.row]

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
            let stock = stockRecords[row]
            controller?.stockSymbol = stock.stockSymbol
//            controller?.company = stock.company
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
        let removeItem = stockRecords[fromIndexPath.row]
        stockRecords.remove(at: fromIndexPath.row)
        stockRecords.insert(removeItem, at: to.row)
        
        container.saveContext()
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

