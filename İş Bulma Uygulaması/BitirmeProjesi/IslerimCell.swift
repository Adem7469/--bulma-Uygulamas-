//
//  IslerimCell.swift
//  BitirmeProjesi
//
//  Created by Adem Basaran on 19.01.2024.
//

import UIKit

class IslerimCell: UITableViewCell {

    
    @IBOutlet weak var pozisyonLabel: UILabel!
    @IBOutlet weak var isyeriLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
