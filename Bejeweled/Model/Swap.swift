//
//  Swap.swift
//  Bejeweled
//
//  Created by Daniel Defta on 18/12/2017.
//  Copyright © 2017 Daniel Defta. All rights reserved.
//

import Foundation
struct Swap: CustomStringConvertible, Hashable {
    let starA: Star
    let starB: Star
    
    init(starA: Star, starB: Star) {
        self.starA = starA
        self.starB = starB
    }
    
    var description: String {
        return "swap \(starA) with \(starB)"
    }
    
    var hashValue: Int {
        return starA.hashValue ^ starB.hashValue
    }
}

func ==(lhs: Swap, rhs: Swap) -> Bool {
    return (lhs.starA == rhs.starA && lhs.starB == rhs.starB) ||
        (lhs.starB == rhs.starA && lhs.starA == rhs.starB)
}
