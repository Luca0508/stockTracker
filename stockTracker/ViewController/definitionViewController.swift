//
//  definitionViewController.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/4/3.
//

import UIKit
import iosMath

class definitionViewController: UIViewController {

    @IBOutlet weak var earningMathLabel: MTMathUILabel!
    @IBOutlet weak var avgPriceMathLabel: MTMathUILabel!
    @IBOutlet weak var avgDollarCostMathLabel: MTMathUILabel!
    @IBOutlet weak var EarningDefinitionLabel: UILabel!
    @IBOutlet weak var AvgPriceDefinitionLabel: UILabel!
    @IBOutlet weak var AvgDollarCostDefinitionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AvgDollarCostDefinitionLabel.text = "Average amount of money you cost\n - Amount will be negative while buying and positive while selling"
        
        avgDollarCostMathLabel.latex = "Amount = price \\times shares \\\\  \\text{Average Dollar Cost} = \\frac{\\sum_{i=1}^N Amount_i}{\\text{Number of Shares}} "
        avgDollarCostMathLabel.textColor = .white
        
        AvgPriceDefinitionLabel.text = "Average cost of you holding stock\n - average price won't be changed while selling the stock"
        avgPriceMathLabel.latex = "\\text{Average Price (AvgPrice)} = \\\\ \\frac{AvgPrice_{prev} \\times shares_{prev} + Price \\times Shares}{\\text{Total Number of Shares}}"
        avgPriceMathLabel.textColor = .white
        
        EarningDefinitionLabel.text = " - Depends on Average Price\n - only changes while selling"
        earningMathLabel.latex = "\\text{Earning} = (price \\times AvgPrice ) \\times shares"
        earningMathLabel.textColor = .white
        

        // Do any additional setup after loading the view.
    }
    
   
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
