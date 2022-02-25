//
//  watchListTableViewCell.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/2/22.
//

import UIKit

class watchListTableViewCell: UITableViewCell {
    @IBOutlet weak var companyNameLabel: UILabel!
    
    @IBOutlet weak var DayHighLowLabel: UILabel!
    @IBOutlet weak var DayChangeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
