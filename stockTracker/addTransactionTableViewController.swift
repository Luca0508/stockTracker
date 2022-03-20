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
    var selectedStockSymbol : String?
    
    var shareCellBackgroundColor = UIColor(red: 0, green: 150/255, blue: 0, alpha: 0.3)
    var selectedSegmentColor = UIColor(red: 0, green: 150/255, blue: 0, alpha: 0.8)
        

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
        buyActionSegmentedControl.selectedSegmentTintColor = selectedSegmentColor

    }

    // close the keyboard when the user tap the screen
    @objc func keyboardDismiss(){
        self.view.endEditing(true)
    }
    
    // set the color depending on segmented control
    @IBAction func clickSegmentControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            sender.selectedSegmentTintColor = UIColor(red: 0, green: 150/255, blue: 0, alpha: 0.8)
            totalLabel.textColor = UIColor(red: 0, green: 150/255, blue: 0, alpha: 1)
            shareCellBackgroundColor = UIColor(red: 0, green: 150/255, blue: 0, alpha: 0.3)
            
            tableView.reloadData()
            
        }else{
            sender.selectedSegmentTintColor = UIColor(red: 200/255, green: 0, blue: 0, alpha: 0.8)
            totalLabel.textColor = UIColor(red: 200/255, green: 0, blue: 0, alpha: 1)
            shareCellBackgroundColor = UIColor(red: 210/255, green: 0, blue: 0, alpha: 0.4)
            
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 3{
            cell.backgroundColor = shareCellBackgroundColor
        }
    }
    
    // set the back button from navigation bar
    func setBackButton(){
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func updateUI(){
        if let transaction = getTransaction{
            stockSymbol =  transaction.stockSymbol
            selectedStockSymbol = stockSymbol
            stockSymbolLabel.text = stockSymbol
            setStockSymbolFont()
            price = transaction.price
            priceTextField.text = transaction.price.description
            shares = transaction.shares
            sharesTextField.text = Int(abs(transaction.shares)).description
            total = transaction.total
            totalLabel.text = abs(total).description
            
            if transaction.buyAction == "BUY"{
                buyActionSegmentedControl.selectedSegmentIndex = 0
                totalLabel.textColor = UIColor(red: 0, green: 150/255, blue: 0, alpha: 1)
                shareCellBackgroundColor = UIColor(red: 0, green: 150/255, blue: 0, alpha: 0.3)
                                
            }else{
                buyActionSegmentedControl.selectedSegmentIndex = 1
                totalLabel.textColor = UIColor(red: 200/255, green: 0, blue: 0, alpha: 1)
                shareCellBackgroundColor = UIColor(red: 210/255, green: 0, blue: 0, alpha: 0.4)
                selectedSegmentColor = UIColor(red: 200/255, green: 0, blue: 0, alpha: 0.8)
                
            }
            
            tradeDatePicker.date = transaction.tradeDate!
            
        }else if let stockSymbol = stockSymbol {
            selectedStockSymbol = stockSymbol
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
            if selectedStockSymbol == nil{
                performSegue(withIdentifier: "showSearchStock", sender: self)
            }else{
                let alertController = UIAlertController(title: "Warning!!!", message: "Cannot Edit Stock Here", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertController, animated: true, completion: nil)
            }
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
//                if let controller = storyboard?.instantiateViewController(withIdentifier: "\(transactionDetailTableViewController.self)") as? transactionDetailTableViewController{
//                    navigationController?.pushViewController(controller, animated: true)
//                }

            }
        }
    }
    func checkSharesAndTotal(transaction : TransactionRecord){
        if var shares = shares{
            if buyActionSegmentedControl.selectedSegmentIndex == 0 {
                newTransaction?.buyAction = "BUY"
                if total > 0 {
                    total = total * -1.0
                }
                if shares < 0 {
                    shares = shares * -1.0
                }
            }else{
                newTransaction?.buyAction = "SELL"
                if total < 0 {
                    total = total * -1.0
                }
                if shares > 0 {
                    shares = shares * -1.0
                }
            }
        }
    }
    
    // deal with the data that will send back when the user want to edit the transaction
    func editTransactionData(){
        if let price = price,
           var shares = shares,
           let stockSymbol = stockSymbol{
            
            newTransaction = getTransaction
            newTransaction?.stockSymbol = stockSymbol
            newTransaction?.price = price
            
            newTransaction?.tradeDate = tradeDatePicker.date
            
            if buyActionSegmentedControl.selectedSegmentIndex == 0 {
                newTransaction?.buyAction = "BUY"
                if total > 0 {
                    total = total * -1.0
                }
                if shares < 0 {
                    shares = shares * -1.0
                }
            }else{
                newTransaction?.buyAction = "SELL"
                if total < 0 {
                    total = total * -1.0
                }
                if shares > 0 {
                    shares = shares * -1.0
                }
            }
            newTransaction?.total = total
            newTransaction?.shares = shares
            
            print("Edit Sucessfully")
            
        }
    }
    
    // deal with the data that will send back when user want to add transaction
    func addTransactionData(){
        let tradeDate = tradeDatePicker.date
        
        
        if let price = price,
           var shares = shares,
           let stockSymbol = stockSymbol{
            
            let transactionRecord = TransactionRecord(context: appDelegate.persistentContainer.viewContext)
            
            if buyActionSegmentedControl.selectedSegmentIndex == 0 {
                transactionRecord.buyAction = "BUY"
                if total > 0 {
                    total = total * -1.0
                }
                if shares < 0 {
                    shares = shares * -1.0
                }
            }else{
                transactionRecord.buyAction = "SELL"
                if total < 0 {
                    total = total * -1.0
                }
                if shares > 0 {
                    shares = shares * -1.0
                }
            }

            
            transactionRecord.price = price
            transactionRecord.shares = shares
            transactionRecord.total = total
            
            transactionRecord.tradeDate = tradeDate
            transactionRecord.stockSymbol = stockSymbol
            self.newTransaction = transactionRecord
            
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
