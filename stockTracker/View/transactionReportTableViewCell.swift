//
//  transactionReportTableViewCell.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/3/4.
//

import UIKit

class transactionReportTableViewCell: UITableViewCell {

    @IBOutlet weak var stockSymbolLabel: UILabel!
    
    @IBOutlet weak var sharesLabel: UILabel!
    
    @IBOutlet weak var earningLabel: UILabel!
    @IBOutlet weak var avgPriceLabel: UILabel!
    
    
    @IBOutlet weak var moneyBalanceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
