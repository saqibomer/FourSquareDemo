//
//  HomeTableViewCell.swift
//  FourSquareDemo
//
//  Created by Saqib Omer on 13/11/2017.
//  Copyright © 2017 KaboomLab. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    // Properties
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
