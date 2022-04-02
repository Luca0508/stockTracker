//
//  importFileViewController.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/3/30.
//

import UIKit
import UniformTypeIdentifiers
import CodableCSV
import CoreData

class importFileViewController: UIViewController, UIDocumentPickerDelegate{
    
    var container : NSPersistentContainer!
    var fetchedResultController : NSFetchedResultsController<TransactionRecord>!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func importFile(_ sender: Any) {
        
        let supportedFile : [UTType] = [UTType.data]
        
        let DocumentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: supportedFile, asCopy: true)
        DocumentPickerController.delegate = self
        DocumentPickerController.allowsMultipleSelection = false
    
        
        present(DocumentPickerController, animated: true, completion: nil)
        
        
        
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print("file was selected")
        
        let context = appDelegate.persistentContainer.viewContext
        var importedTransactionRecords = [TransactionRecord]()

        
        let rows = NSArray(contentsOfCSVURL: url, options:CHCSVParserOptions.sanitizesFields)!
        var changeSymbolSet = Set<String>()
        var correctFormat = true
        
        for (index, rowContent) in rows.enumerated(){
            if index != 0, let rowString = rowContent as? [String]{
                let importFileStruct = stockTracker.importFile.init(raw:rowString)
                let transactionRecord = TransactionRecord(context: appDelegate.persistentContainer.viewContext)
                
                if let symbol = importFileStruct.symbol,
                   let date = importFileStruct.date,
                   let price = importFileStruct.price,
                   let shares = importFileStruct.shares,
                   let buyAction = importFileStruct.buyAction,
                   let total = importFileStruct.total{
                    
                    transactionRecord.stockSymbol = symbol
                    transactionRecord.tradeDate = date
                    transactionRecord.price = price
                    transactionRecord.shares = shares
                    transactionRecord.buyAction = buyAction
                    transactionRecord.total = total
                    
                    changeSymbolSet.insert(symbol)
                    importedTransactionRecords.append(transactionRecord)
                }else{
                    correctFormat = false
                    
                    let alertController = UIAlertController(title: "Warning!!!", message: "The format of imported .csv file may be wrong.(error in line : \(index) of the imported file). Please follow the instruction below", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(alertController, animated: true, completion: nil)
                    
                    break
                }
                
            }else{
                print("Failed to convert [String] or Line 1")
            }
        }
        
        if correctFormat{
            for transaction in importedTransactionRecords{
                context.insert(transaction)
            }
            appDelegate.persistentContainer.saveContext()
            
            if let navigationController = tabBarController?.viewControllers?[0] as? UINavigationController,
               let mainController = navigationController.viewControllers.first as? transactionReportTableViewController {
                mainController.changeImportedSymbolSet = changeSymbolSet
            }
            
            let alertController = UIAlertController(title: "Message", message: "Import the File Successfully!!! Please check them in Transaction Report.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            present(alertController, animated: true, completion: nil)
            
        }else {
            print("the format of imported file is incorrect")
        }
    }
}


