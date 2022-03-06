//
//  transactionRecord.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/2/28.
//

import Foundation
import UIKit

struct stockTransaction : Codable{
    var stockSymbol : String
    var company : String
    var transactions : Array<transaction>
    
    
    static let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    static func loadTransactionRecord() -> [stockTransaction]?{
        let url = documentDirectory.appendingPathComponent("transactionRecords")
        guard let data = try? Data(contentsOf: url) else {return nil}
        let decoder = JSONDecoder()
        return try? decoder.decode([stockTransaction].self, from: data)
        
    }
    
    static func saveTransactionRecord(_ transactionRecord : [Self]){
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(transactionRecord) else { return }
        let url = documentDirectory.appendingPathComponent("transactionRecords")
        try? data.write(to: url)
    }
}

struct transaction : Codable{
    var buyAction : String
    var price : Double
    var shares : Double
    var total : Double
    var tradeDate : Date

}
