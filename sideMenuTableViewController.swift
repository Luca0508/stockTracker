//
//  sideMenuTableViewController.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/4/3.
//

import UIKit

class sideMenuTableViewController: UITableViewController {
    
    let contentList = ["Definition"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "sideMenuTableViewCell")
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .lightGray
        tableView.backgroundColor = .darkGray

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return contentList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sideMenuTableViewCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = contentList[indexPath.row]
        content.textProperties.color = .white
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        cell.backgroundColor = .darkGray

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            
            
            guard let controller =
                    UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "definitionViewController") as? definitionViewController else {
                print("fail")
                return }
            
            present(controller, animated: true, completion: nil)
            
        }
    }
    
}
