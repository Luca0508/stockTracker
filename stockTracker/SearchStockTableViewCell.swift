//
//  SearchStockTableViewCell.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/2/23.
//

import UIKit

class SearchStockTableViewCell:
    UITableViewCell {
   
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
