//
//  addTransactionTableViewController.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/3/1.
//

import UIKit
import CoreData


class addTransactionTableViewController: UITableViewController {
    
   
    var container : NSPersistentContainer!
    
    var stockRecords = [StockRecord]()

    @IBOutlet weak var stockSymbolLabel: UILabel!
    
    @IBOutlet weak var buyActionSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var priceTextField: UITextField!
    
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var sharesTextField: UITextField!
    
    @IBOutlet weak var tradeDatePicker: UIDatePicker!
    
    var total : Double = 0
    var price : Double?
    var shares : Double?
    var stockSymbol : String?
    var company : String?
    
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
        fetchStockRecords()

        
        stockSymbolLabel.text = "Tap It to Insert Info"
        stockSymbolLabel.textColor = .lightGray
        stockSymbolLabel.font = UIFont.systemFont(ofSize: 15, weight: .light)
        tradeDatePicker.backgroundColor = .white
        
        tableView.rowHeight = 90
        
        // close the keyboard when the user tap the screen
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.keyboardDismiss))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        setBackButton()
    }

    // close the keyboard when the user tap the screen
    @objc func keyboardDismiss(){
        self.view.endEditing(true)
    }
    
    func setBackButton(){
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    
    // update the totalLabel as the textfield of price and shares changed
    @IBAction func calculateTotal(_ sender: UITextField) {
        
        if let priceText = priceTextField.text,
           let sharesText = sharesTextField.text{
            price = Double(priceText) ?? 0
            shares = Double(sharesText) ?? 0
            total = price! * shares!
            totalLabel.text = total.description
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            performSegue(withIdentifier: "showSearchStock", sender: self)
        }
    }
    
    
    @IBSegueAction func searchStockSymbol(_ coder: NSCoder) -> SearchStockTableViewController? {
        let searchStockTableViewController = SearchStockTableViewController(coder: coder)
        searchStockTableViewController?.delegate = self
        return searchStockTableViewController
    }
    
    func showAlert(warningInput : String){
        let alertController = UIAlertController(title: "Warning !!!", message: "Please Insert the correct Information for \(warningInput)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "showTransactionReport"{
            if priceTextField.text?.isEmpty == true ||
               price == 0.0 {
                
                showAlert(warningInput: "price")
                return false
            } else if sharesTextField.text?.isEmpty == true ||
                        shares == 0.0 {
                
                showAlert(warningInput: "shares")
                return false
            } else if stockSymbolLabel.text == "Tap It to Insert Info"{
                
                showAlert(warningInput: "stock symbol")
                return false
            }
        }
        
                
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTransactionReport"{
            addTransactionData()
        }
    }
    
    func fetchStockRecords(){
        do{
            self.stockRecords = try container.viewContext.fetch(StockRecord.fetchRequest())
            
            print("fetch in addTransaction")

        }catch{
            print(error)
        }
        
        
    }
    
    
    

    func addTransactionData(){
                            
        let tradeDate = tradeDatePicker.date
        
        let buyAction : String
        
        if buyActionSegmentedControl.selectedSegmentIndex == 0 {
            buyAction = "BUY"
        }else{
            buyAction = "SELL"
        }
        
       
        if let price = price,
           let shares = shares,
           let stockSymbol = stockSymbol,
           let company = company {
            
            let transaction = TransactionRecord(context: container.viewContext)
            transaction.price = price
            transaction.shares = shares
            transaction.total = total
            transaction.buyAction = buyAction
            transaction.tradeDate = tradeDate
            
            if let index = stockRecords.firstIndex(where: {$0.stockSymbol == stockSymbol}){
                stockRecords[index].addToTransactionInfo(transaction)
                
            }else{
                let stock = StockRecord(context: container.viewContext)
                stock.stockSymbol = stockSymbol
                stock.company = company
                stock.addToTransactionInfo(transaction)
            }
            print("addTransaction")
            
            container.saveContext()
            
            
//            if let index = transactionRecord.firstIndex(where: {$0.stockSymbol == stockSymbol}){
//                transactionRecord[index].transactions.append(transaction(buyAction: buyAction, price: price, shares: shares, total: total, tradeDate: tradeDate))
//
//            }else{
//                transactionRecord.append(stockTransaction(stockSymbol: stockSymbol, company: company, transactions: [transaction(buyAction: buyAction, price: price, shares: shares, total: total, tradeDate: tradeDate)]))
//            }
        }
    }
    // MARK: - Table view data source

    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

extension addTransactionTableViewController : SearchStockTableViewControllerDelegate{
    func searchStockTableViewController( _ controller : SearchStockTableViewController, addStock stock : stockFullName){
        stockSymbolLabel.text = stock.Symbol
        stockSymbolLabel.textColor = .white
        stockSymbolLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        stockSymbol = stock.Symbol
        company = stock.CompanyName
    }
}
