//
//  SearchItem.swift
//  ScoreBoard
//
//  Created by Trey Hope on 9/29/17.
//  Copyright © 2017 Trey Hope. All rights reserved.
//

import UIKit

class SearchItem: UITableViewCell {
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePic.round(borderWidth: 2.0, borderColor: GMColor.grey500Color())
    }
}
