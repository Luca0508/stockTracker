//
//  websocketStockInfo.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/3/17.
//

import Foundation
import UIKit

struct websocketStockInfo : Codable{
    var type : String
    var data : [priceData]
}

struct priceData : Codable{
    var s : String // symbol
    var p : Double // price
}
