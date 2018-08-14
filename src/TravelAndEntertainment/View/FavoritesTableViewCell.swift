//
//  FavoritesTableViewCell.swift
//  TravelAndEntertainment
//
//  Created by Raj Thaker on 4/9/18.
//  Copyright © 2018 Raj Thaker. All rights reserved.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var placeAddr: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
