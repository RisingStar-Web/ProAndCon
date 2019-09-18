//
//  HistoryTableViewCell.swift
//  ProAndCon
//
//  Created by Роман Кабиров on 10.12.2017.
//  Copyright © 2017 Logical Mind. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelResult: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .clear
    }
    
    func load(date: Date, name: String, result: ProAndConResult) {
        labelDate.text = Utils.getHumanDate(date)
        labelName.text = name
        labelResult.text = Utils.getShownResult(result: result)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)

        // Configure the view for the selected state
    }

}
