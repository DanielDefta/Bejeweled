//
//  PlayerCellTableViewCell.swift
//  Bejeweled
//
//  Created by Daniel Defta on 05/01/2018.
//  Copyright © 2018 Daniel Defta. All rights reserved.
//

import UIKit

class PlayerCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var highscoreLabel: UILabel!
    
    var player: Player! {
        didSet{
            nameLabel.text = player.name
            highscoreLabel.text = "\(player.highscore)"
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
