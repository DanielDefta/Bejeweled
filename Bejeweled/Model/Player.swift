//
//  Player.swift
//  Bejeweled
//
//  Created by Daniel Defta on 05/01/2018.
//  Copyright © 2018 Daniel Defta. All rights reserved.
//
import RealmSwift

class Player: Object {
    @objc dynamic var name = ""
    @objc dynamic var highscore = 0
    @objc dynamic var coins = 0
    @objc dynamic var aantalShuffle = 0
    
    convenience init(name: String){
        self.init()
        self.name = name
        self.highscore = 0
        self.coins = 0
        self.aantalShuffle = 0
    }
}
