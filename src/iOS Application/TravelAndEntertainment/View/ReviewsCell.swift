//
//  ReviewsCell.swift
//  TravelAndEntertainment
//
//  Created by Raj Thaker on 4/10/18.
//  Copyright © 2018 Raj Thaker. All rights reserved.
//

import UIKit
import Cosmos

class ReviewsCell: UITableViewCell {

    @IBOutlet weak var reviewersPhoto: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var reviewText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
