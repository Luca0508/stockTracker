//
//  WatchListTableViewController.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/2/22.
//

import UIKit

class WatchListTableViewController: UITableViewController {

    var watchList = [stockPriceInfo](){
        didSet{
            stockPriceInfo.saveWatchList(watchList)
        }
    }
    
    
    var stockprice : stockPriceInfo?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let watchList = stockPriceInfo.loadWatchList(){
            self.watchList = watchList
        }
        
        tableView.rowHeight = 65

        for stock in watchList{
            fetchExistingItem(stockInfo: stock)
        }
        
        let timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            for stock in self.watchList{
                self.fetchExistingItem(stockInfo: stock)
            }
            self.tableView.reloadData()
        }
        timer.fire()
    }
    func fetchItem(stockInfo:stockFullName){
        let token = "c7occ8iad3idf06mr490"
        
        var stockUrlComponent = URLComponents(string: "https://finnhub.io/api/v1/quote")
        stockUrlComponent?.queryItems = [
            URLQueryItem(name: "symbol", value: stockInfo.Symbol),
            URLQueryItem(name: "token", value: token)
        ]
        
        URLSession.shared.dataTask(with: (stockUrlComponent?.url)!) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                do{
                    var apiResponse = try decoder.decode(stockPriceInfo.self, from: data)
                    apiResponse.symbol = stockInfo.Symbol
                    apiResponse.company = stockInfo.CompanyName
                    self.watchList.append(apiResponse)
                    
                }catch{
                    print(error)
                }
                
            }
        }.resume()
        
    }
    
    func fetchExistingItem(stockInfo:stockPriceInfo){
        let token = "c7occ8iad3idf06mr490"
        
        var stockUrlComponent = URLComponents(string: "https://finnhub.io/api/v1/quote")
        stockUrlComponent?.queryItems = [
            URLQueryItem(name: "symbol", value: stockInfo.symbol),
            URLQueryItem(name: "token", value: token)
        ]
        
        URLSession.shared.dataTask(with: (stockUrlComponent?.url)!) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                do{
                    var apiResponse = try decoder.decode(stockPriceInfo.self, from: data)
                    
                    if let index = self.watchList.firstIndex(where:{$0.symbol == stockInfo.symbol}){
                        apiResponse.symbol = self.watchList[index].symbol
                        apiResponse.company = self.watchList[index].company
                        
                        self.watchList[index] = apiResponse
                        
                    }
                    
                    DispatchQueue.main.sync {
                        self.tableView.reloadData()
                    }
                }catch{
                    print(error)
                }
                
            }
        }.resume()

    }

    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return watchList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(watchListTableViewCell.self)", for: indexPath) as? watchListTableViewCell else{return UITableViewCell()}
        
        let stock = watchList[indexPath.row]
        cell.stockLabel.text = stock.symbol
        cell.companyNameLabel.text = stock.company
        cell.DayHighLowLabel.text = "\(String(describing: stock.h))\n\(String(describing: stock.l))"
        cell.priceLabel.text = stock.c.description
        if stock.d >= 0 {
            cell.DayChangeLabel.textColor = .green
        }else{
            cell.DayChangeLabel.textColor = .red
        }
        
        
        cell.DayChangeLabel.text = "\(String(describing: stock.d))\n\(String(format: "%.2f", stock.dp ))%"


        return cell
    }
    
    @IBSegueAction func addStock(_ coder: NSCoder) -> SearchStockTableViewController? {
        let searchController = SearchStockTableViewController(coder: coder)
        searchController?.delegate = self
        return searchController
    }
    
   
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        watchList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    @IBAction func clickEditButton(_ sender: UIBarButtonItem) {
        super.setEditing(!tableView.isEditing, animated: true)
        sender.title = isEditing ? "Done" : "Edit"
        
        tableView.allowsSelectionDuringEditing = true
        tableView.reloadData()
    }
    

    
    // Override to support rearranging the table view.
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let removeItem = watchList[fromIndexPath.row]
        watchList.remove(at: fromIndexPath.row)
        watchList.insert(removeItem, at: to.row)
    

    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    

}
extension WatchListTableViewController : SearchStockTableViewControllerDelegate{
    func searchStockTableViewController(_ controller: SearchStockTableViewController, addStock stock: stockFullName) {
        if !(watchList.contains(where: { stockInfo in
            stockInfo.symbol == stock.Symbol
        })){
            fetchItem(stockInfo: stock)
        }
    }
}
