//
//  SearchStockTableViewController.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/2/23.
//

import UIKit
import CodableCSV

protocol SearchStockTableViewControllerDelegate {
    func searchStockTableViewController( _ controller : SearchStockTableViewController, addStock stock : stockFullName)
}

class SearchStockTableViewController: UITableViewController {
    
    var searching = false
    var delegate : SearchStockTableViewControllerDelegate?
    var stockList = stockFullName.data
    
    lazy var filterStockList = stockList
    var stock : stockFullName?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        searchBarSetting()
        tableView.rowHeight = 65
    
       
    }
    

    func searchBarSetting(){
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.barStyle = .black
        searchController.searchBar.searchTextField.textColor = .white
        searchController.automaticallyShowsCancelButton = true
    }
   

    // MARK: - Table view data source

    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching{
            return filterStockList.count
        }
        return 0
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(SearchStockTableViewCell.self)", for: indexPath) as? SearchStockTableViewCell else {return UITableViewCell()}
        

        let stock = filterStockList[indexPath.row]
        cell.symbolLabel.text = stock.Symbol
        cell.companyNameLabel.text = stock.CompanyName

        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stock = filterStockList[indexPath.row]
//        let stockPriceInfo = fetchItem(stockInfo: stock)
        
        delegate?.searchStockTableViewController(self, addStock: stock)
        navigationController?.popViewController(animated: true)
    }
    

}

extension SearchStockTableViewController : UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text,
           searchText.isEmpty == false{
            searching = true
            filterStockList = stockList.filter({ stock in
                stock.symbolName.localizedStandardContains(searchText)
            })
        }else{
            searching = false
            filterStockList = stockList
        }
        
        tableView.reloadData()
    }
}
