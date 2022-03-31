//
//  stockFullName.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/3/30.
//

import Foundation
import UIKit
import CodableCSV

struct stockFullName : Codable{
    var Symbol : String
    let symbolName :String
    var CompanyName : String{
        symbolName.components(separatedBy: "_")[1]
    }
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

