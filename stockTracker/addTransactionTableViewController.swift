//
//  addTransactionTableViewController.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/3/1.
//

import UIKit
import CoreData

protocol addTransactionTableViewControllerDelegate{
    func AddTransactionTableViewController(_ controller : addTransactionTableViewController, sendTransaction transaction:TransactionRecord)
}

class addTransactionTableViewController: UITableViewController {
    
   
    var container : NSPersistentContainer!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var newTransaction : TransactionRecord?
    var getTransaction: TransactionRecord?
    
    var delegate : addTransactionTableViewControllerDelegate?

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
    

    override func viewDidLoad() {
        super.viewDidLoad()
  
        stockSymbolLabel.text = "Tap It to Insert Info"
        stockSymbolLabel.textColor = .lightGray
        stockSymbolLabel.font = UIFont.systemFont(ofSize: 15, weight: .light)
        tradeDatePicker.backgroundColor = .white
        
        tableView.rowHeight = 90
        
        // close the keyboard when the user tap the screen
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.keyboardDismiss))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
//        setBackButton()
    }

    // close the keyboard when the user tap the screen
    @objc func keyboardDismiss(){
        self.view.endEditing(true)
    }
    
    // set the back button from navigation bar
    func setBackButton(){
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func updateUI(){
        if let transaction = getTransaction{
            stockSymbol =  transaction.stockSymbol
            stockSymbolLabel.text = stockSymbol
            setStockSymbolFont()
            price = transaction.price
            priceTextField.text = transaction.price.description
            shares = transaction.shares
            sharesTextField.text = Int(transaction.shares).description
            total = transaction.total
            totalLabel.text = transaction.total.description
            
            if transaction.buyAction == "BUY"{
                buyActionSegmentedControl.selectedSegmentIndex = 0
            }else{
                buyActionSegmentedControl.selectedSegmentIndex = 1
            }
            
            tradeDatePicker.date = transaction.tradeDate!
            
        }else if let stockSymbol = stockSymbol {
            stockSymbolLabel.text = stockSymbol
            setStockSymbolFont()
        }else{
            stockSymbolLabel.text = "Tap It to Insert Info"
            stockSymbolLabel.textColor = .lightGray
            stockSymbolLabel.font = UIFont.systemFont(ofSize: 15, weight: .light)
        }
    }
    
    // set the font of stockSymbolLabel while having the stock symbol
    func setStockSymbolFont(){
        stockSymbolLabel.textColor = .white
        stockSymbolLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
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
    
    // go to SearchStockTableViewController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            performSegue(withIdentifier: "showSearchStock", sender: self)
        }
    }
    
    // use delegate the send the data between this view controller and searchStockTableViewController
    @IBSegueAction func searchStockSymbol(_ coder: NSCoder) -> SearchStockTableViewController? {
        let searchStockTableViewController = SearchStockTableViewController(coder: coder)
        searchStockTableViewController?.delegate = self
        return searchStockTableViewController
    }
    
    // show the alert when the input info is not proper when the user want to save the transaction
    func showAlert(warningInput : String){
        let alertController = UIAlertController(title: "Warning !!!", message: "Please Insert the correct Information for \(warningInput)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    // detect whether the input info is proper or not
    func checkInputData() -> Bool{
        if priceTextField.text?.isEmpty == true || price == 0.0 {
            showAlert(warningInput: "price")
            return false
        } else if sharesTextField.text?.isEmpty == true || shares == 0.0 {
            showAlert(warningInput: "shares")
            return false
        } else if stockSymbolLabel.text == "Tap It to Insert Info"{
            showAlert(warningInput: "stock symbol")
            return false
        }
        return true
    }
    
    
    @IBAction func clickSaveButton(_ sender: Any) {
        
        if checkInputData(){
            if let _ = getTransaction {
                print("check edit transaction data")
                editTransactionData()
            }else{
                print("check add transaction data")
                addTransactionData()
            }
            if let newTransaction = newTransaction{
                delegate?.AddTransactionTableViewController(self, sendTransaction: newTransaction)
                
                navigationController?.popViewController(animated: true)
                print("delegate check")
            }else{
                print("delegate check fail")
            }
        }
                
    }
    
    
    // deal with the data that will send back when the user want to edit the transaction
    func editTransactionData(){
        if let price = price,
           let shares = shares,
           let stockSymbol = stockSymbol{
            
            newTransaction = getTransaction
            newTransaction?.stockSymbol = stockSymbol
            newTransaction?.price = price
            newTransaction?.shares = shares
            newTransaction?.total = total
            newTransaction?.tradeDate = tradeDatePicker.date
            
            if buyActionSegmentedControl.selectedSegmentIndex == 0 {
                newTransaction?.buyAction = "BUY"
            }else{
                newTransaction?.buyAction = "SELL"
            }
            
            print("Edit Sucessfully")
            
        }
    }
    
    // deal with the data that will send back when user want to add transaction
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
           let stockSymbol = stockSymbol{
            
            let transactionRecord = TransactionRecord(context: appDelegate.persistentContainer.viewContext)
            transactionRecord.price = price
            transactionRecord.shares = shares
            transactionRecord.total = total
            transactionRecord.buyAction = buyAction
            transactionRecord.tradeDate = tradeDate
            transactionRecord.stockSymbol = stockSymbol
            self.newTransaction = transactionRecord
            
            print("addTransaction")
        }
    }
}

// delegate to send the data between this and searchStockTaleViewController (deal the data when data come in)
extension addTransactionTableViewController : SearchStockTableViewControllerDelegate{
    func searchStockTableViewController( _ controller : SearchStockTableViewController, addStock stock : stockFullName){
        stockSymbolLabel.text = stock.Symbol
        setStockSymbolFont()
        
        stockSymbol = stock.Symbol
        company = stock.CompanyName
    }
}
