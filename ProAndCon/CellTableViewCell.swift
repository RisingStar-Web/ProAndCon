//
//  CellTableViewCell.swift
//  ProAndCon
//
//  Created by Роман Кабиров on 13.12.2017.
//  Copyright © 2017 Logical Mind. All rights reserved.
//

import UIKit

class CellTableViewCell: UITableViewCell {

    @IBOutlet weak var labelText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .clear
    }
    
    func setText(_ text: String) {
        labelText.text = text
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)

        // Configure the view for the selected state
    }

}
