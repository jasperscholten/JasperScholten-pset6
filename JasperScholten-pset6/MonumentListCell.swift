//
//  MonumentListCell.swift
//  JasperScholten-pset6
//
//  Created by Jasper Scholten on 08-12-16.
//  Copyright © 2016 Jasper Scholten. All rights reserved.
//

import UIKit

class MonumentListCell: UITableViewCell {


    
    @IBOutlet weak var monumentListName: UILabel!
    @IBOutlet weak var monumentListAdress: UILabel!
    @IBOutlet weak var addFavorite: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
