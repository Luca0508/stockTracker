//
//  stockInfo.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/2/22.
//

import Foundation
import UIKit
import CodableCSV

struct stockPriceInfo: Codable{
    var symbol : String?
    var company : String?
    var c: Double // current price
    var d: Double // change
    var dp: Double // percent change
    var h : Double // high price of the day
    var l : Double// low price of the day
//    let o : Double // open pirce of the day
//    let pc : Double // previous close price
    static var documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    static func loadWatchList() -> [stockPriceInfo]?{
        let url = documentDirectory.appendingPathComponent("watchList")
        guard let data = try? Data(contentsOf: url) else {return nil}
        
        let decoder = JSONDecoder()
        return try? decoder.decode([stockPriceInfo].self, from: data)
    }
    
    static func saveWatchList(_ watchList: [Self]){
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(watchList) else {return }
        let url = documentDirectory.appendingPathComponent("watchList")
        try? data.write(to: url)
        
    }
    
    
    
}

struct stockFullName : Codable{
    var Symbol : String
    let symbolName :String
    var CompanyName : String{
        symbolName.components(separatedBy: "_")[1]
    }
    
    

}


struct searchResult : Codable{
    let result : [searchStockInfo]
}

struct searchStockInfo : Codable{
    let symbol : String
    let description : String
}




extension stockFullName {
    static var data :[Self]{
        var array = [Self]()
        if let data = NSDataAsset(name: "stockList")?.data {
            let decoder = CSVDecoder{
                $0.headerStrategy = .firstLine
            }
            do{
                array = try decoder.decode([Self].self, from: data)
                array = array.filter({!$0.Symbol.contains("^")})
            }catch{
                print(error)
            }
        }
        
        
        return array
    }

}



