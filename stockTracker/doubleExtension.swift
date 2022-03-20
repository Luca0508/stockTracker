//
//  doubleExtension.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/3/20.
//

import Foundation
import UIKit

extension Double{
    func getCurrencyFormat()->String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSeparator = ","
        numberFormatter.groupingSize = 3
        
        return numberFormatter.string(from: NSNumber(value: self))!
    }
    
    func getChangeCurrencyFormat() -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSeparator = ","
        numberFormatter.groupingSize = 3
        numberFormatter.positivePrefix = "+"
        
        return numberFormatter.string(from: NSNumber(value: self))!
    }
    
    func getPercentageFormat() -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        numberFormatter.maximumFractionDigits = 1
        numberFormatter.positivePrefix = "+"
        
        return numberFormatter.string(from: NSNumber(value: self))!
    }
    
    func getSharesFormat() -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSeparator = ","
        numberFormatter.groupingSize = 3
        numberFormatter.positivePrefix = "+"
        
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}
