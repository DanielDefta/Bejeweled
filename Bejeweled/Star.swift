//
//  Star.swift
//  Bejeweled
//
//  Created by Daniel Defta on 18/12/2017.
//  Copyright © 2017 Daniel Defta. All rights reserved.
//

import Foundation
import SpriteKit

enum StarType: Int {
    case unknown = 0, blue, green, orange, purple, red, white, yellow, speciaal
    var spriteName: String {
        let spriteNames = [
            "blue",
            "green",
            "orange",
            "purple",
            "red",
            "white",
            "yellow",
            "speciaal"]
        
        return spriteNames[rawValue - 1]
    }
    
    static func random() -> StarType {
        return StarType(rawValue: Int(arc4random_uniform(8)) + 1)!
    }
}

class Star: Hashable {
    var column: Int
    var row: Int
    let starType: StarType
    var sprite: SKSpriteNode?
    
    var inserted = false
    
    init(column: Int, row: Int, starType: StarType) {
        self.column = column
        self.row = row
        self.starType = starType
    }
    
    var hashValue: Int {
        return row*10 + column
    }
    
}

func ==(lhs: Star, rhs: Star) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}
