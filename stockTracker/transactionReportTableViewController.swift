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
    var fetchedResultController : NSFetchedResultsController<TransactionRecord>!
   
    var transactionRecords = [TransactionRecord]()
    var transaction : TransactionRecord?
    var company : String?
    var uniqueStock : NSArray?
    var symbolList = Array<String>()
    var newSymbol = false
    
    var uniqueFetchedResultController : NSFetchedResultsController<NSFetchRequestResult>!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 70
//        resetAllRecords(in: "TransactionRecord")
        fetchData()
        

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    func fetchData(){
        transactionRecords.removeAll()
        
        let request = NSFetchRequest<TransactionRecord>(entityName: "TransactionRecord")
        let sortDescripter = NSSortDescriptor(key: "tradeDate", ascending: false)
        request.sortDescriptors = [sortDescripter]
        
        let context = container.viewContext
        fetchedResultController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        
        
        do{
            try fetchedResultController.performFetch()
            if let fetchObject = fetchedResultController.fetchedObjects{
                self.transactionRecords = fetchObject
                groupby()
            }
                        
        }catch{
            print("fetch data error in transactionReport : \(error)")
        }
        
    }
    
    func groupby(){
        let groupbyDictionary = Dictionary(grouping: transactionRecords, by:{ $0.stockSymbol})
        symbolList.removeAll()
        for s in groupbyDictionary.keys{
            symbolList.append(s!)
        }
    }
       
    
    
    func resetAllRecords(in entity : String) // entity = Your_Entity_Name
        {

            let context = ( UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            do
            {
                try context.execute(deleteRequest)
                try context.save()
            }
            catch
            {
                print ("There was an error")
            }
        }

    
    func deleteAllData(_ entity:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try container.viewContext.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                container.viewContext.delete(objectData)
            }
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return  symbolList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(transactionReportTableViewCell.self)", for: indexPath) as? transactionReportTableViewCell else {return UITableViewCell()}
        

        cell.stockSymbolLabel.text = symbolList[indexPath.row]
//        cell.companyLabel.text = stock.company
        
        cell.overrideUserInterfaceStyle = .dark

        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "showStockDetail", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? transactionDetailTableViewController,
         let row = tableView.indexPathForSelectedRow?.row{
//            let stock = transactionRecords[row]
//            controller.stockSymbol = stock.stockSymbol
            let symbol = symbolList[row]
            controller.stockSymbol = symbol

        }
        
        if let addController = segue.destination as? addTransactionTableViewController{
            addController.delegate = self
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        container.viewContext.delete(self.fetchedResultController.object(at: indexPath))
        container.saveContext()

    }
}
extension transactionReportTableViewController : addTransactionTableViewControllerDelegate{
    func AddTransactionTableViewController(_ controller : addTransactionTableViewController, sendTransaction transaction : TransactionRecord){
        let context = container.viewContext
        context.insert(transaction)
        container.saveContext()
        tableView.reloadData()
    }
}

extension transactionReportTableViewController : NSFetchedResultsControllerDelegate{

//    func controllerWillChangeContent( _ controller: NSFetchedResultsController<NSFetchRequestResult>){
//        tableView.beginUpdates()
//    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            if let newIndexPath = newIndexPath{
//                tableView.insertRows(at: [newIndexPath], with: .automatic)
//            }
//        case .delete:
//            if let indexPath = indexPath {
//                tableView.deleteRows(at: [indexPath], with: .automatic)
//            }
//        case .move:
//            if let indexPath = indexPath,
//            let newIndexPath = newIndexPath {
//                tableView.moveRow(at: indexPath, to: newIndexPath)
//            }
//        case .update:
//            if let indexPath = indexPath {
//                tableView.reloadRows(at: [indexPath], with: .automatic)
//            }
//        default:
//            tableView.reloadData()
//
//        }
        if let fetchobject = controller.fetchedObjects{
            transactionRecords = fetchobject as! [TransactionRecord]
            groupby()
            tableView.reloadData()

        }

    }
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
//    }


}



