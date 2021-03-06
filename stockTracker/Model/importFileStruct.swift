//
//  importFile.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/3/30.
//

import Foundation
import UIKit
import CodableCSV


struct importFile : Codable{
    var dateString : String
    var description : String
    
    var date: Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.date(from: dateString)
    }
    var descriptionArray : [String]{
        return description.components(separatedBy: " ")
    }
    
    var buyAction : String? {
        if descriptionArray[0] == "Bought"{
            return "BUY"
        }else if descriptionArray[0] == "Sold"{
            return "SELL"
        }else{
            return nil
        }
    }
    
    var symbol : String?{
        return descriptionArray[2]
    }
    
    var price : Double?{
        return Double(descriptionArray[4])
    }
    
    var shares : Double?{
        if let buyAction = buyAction,
           let share = Double(descriptionArray[1]){
            if buyAction == "BUY"{
                return share
            }else {
                return share * -1.0
            }
        }
        return nil
    }
    
    var total: Double?{
        if let price = price,
           let shares = shares{
            return price * shares * -1.0
        }
        return nil
    }
    
    init(raw:[String]) {
        dateString = raw[0]
        description = raw[1]
    }
        
}

