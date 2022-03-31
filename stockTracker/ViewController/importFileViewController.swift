//
//  importFileViewController.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/3/30.
//

import UIKit
import UniformTypeIdentifiers
import CodableCSV

class importFileViewController: UIViewController, UIDocumentPickerDelegate{

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

        var importArray = [stockTracker.importFile]()
        
        let rows = NSArray(contentsOfCSVURL: url, options:CHCSVParserOptions.sanitizesFields)!
        
        for row in rows{
            if let rowString = row as? [String]{
                let importFileStruct = stockTracker.importFile.init(raw:rowString)
                importArray.append(importFileStruct)
                
                print("convert [string] successfully ")
            }else{
                print("Failed to convert [String]")
            }
        }
        importArray.removeFirst()
        print(importArray)

        for transaction in importArray{
            if let symbol = transaction.symbol,
               let date = transaction.date,
               let price = transaction.price,
               let shares = transaction.shares,
               let buyAction = transaction.buyAction{
                
            }else{
                let alertController = UIAlertController(title: "Warning!!!", message: "The format of imported csv file may be wrong. Please follow the instruction to import csv file", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            }
            
                
        }
//        print("price : \(importArray[1].price)")
    }
    
}
