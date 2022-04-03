//
//  definitionViewController.swift
//  
//
//  Created by 蕭鈺蒖 on 2022/4/3.
//

import UIKit

class definitionViewController: UIViewController {

    @IBOutlet weak var EarningDefinitionLabel: UILabel!
    @IBOutlet weak var AvgPriceDefinitionLabel: UILabel!
    @IBOutlet weak var AvgDollarCostDefinitionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AvgDollarCostDefinitionLabel.text = "Average amount of money you cost/n"

        // Do any additional setup after loading the view.
    }
    
    func LabelSetting(label:UILabel){
        label.numberOfLines = 0
        
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
