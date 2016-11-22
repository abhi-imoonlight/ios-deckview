//
//  DeckCell.swift
//  DeckSystem
//
//  Created by Abhinash Khanal on 11/21/16.
//  Copyright © 2016 Moonlighting. All rights reserved.
//

import UIKit

class DeckCell: UITableViewCell {

    @IBOutlet weak var deck: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
