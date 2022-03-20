//
//  stockStatistics.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/3/15.
//

import Foundation
import UIKit

struct stockStatistics : Codable{
    let stockSymbol : String
    var totalQuantity : Double // total amount of shares
    var totalDollarCost : Double // total amount of money you cost (including bought and sold stocks )
    
    // average amount of money you cost (including bought and sold stocks)
    var AverageDollarCost : Double{
        if totalQuantity == 0{
            return 0
        }else{
            return totalDollarCost / totalQuantity * -1.0
        }
    }
    
    
    
    // average cost of you holding stock
    var AveragePrice: Double
    var prevAveragePrice : Double
    var AveragePriceChange : Double{
        return AveragePrice - prevAveragePrice
    }
    var AveragePriceChangePercentage : Double{
        if prevAveragePrice == 0 {
            return 0
        }
        return AveragePriceChange / prevAveragePrice 
    }
    
    var earning : Double // earning depend on average price
    var earningChange : Double
    
        
    static let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    static func loadStockStatistics() -> [stockStatistics]?{
        let url = documentDirectory.appendingPathComponent("stockStatistics")
        guard let data = try? Data(contentsOf: url) else {return nil}
        let decoder = JSONDecoder()
        return try? decoder.decode([stockStatistics].self, from: data)

    }

    static func saveStockStatistics(_ stockStatistics : [Self]){
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(stockStatistics) else { return }
        let url = documentDirectory.appendingPathComponent("stockStatistics")
        try? data.write(to: url)
    }
    
}

