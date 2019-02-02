//
//  RewardTableViewCell.swift
//  Rolex
//
//  Created by J J Feddock on 1/20/19.
//  Copyright © 2019 JF Corporation. All rights reserved.
//

import UIKit
import Parse

class RewardTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var mainBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
