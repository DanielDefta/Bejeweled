//
//  Chain.swift
//  Bejeweled
//
//  Created by Daniel Defta on 23/12/2017.
//  Copyright © 2017 Daniel Defta. All rights reserved.
//

import Foundation

class Chain: Hashable, CustomStringConvertible {
    var stars = [Star]()
    
    enum ChainType: CustomStringConvertible {
        case horizontal
        case vertical
        
        var description: String {
            switch self {
            case .horizontal: return "Horizontal"
            case .vertical: return "Vertical"
            }
        }
    }
    
    var chainType: ChainType
    
    var score = 0
    
    init(chainType: ChainType) {
        self.chainType = chainType
    }
    
    func add(star: Star) {
        stars.append(star)
    }
    
    func firstStar() -> Star {
        return stars[0]
    }
    
    func lastStar() -> Star {
        return stars[stars.count - 1]
    }
    
    var length: Int {
        return stars.count
    }
    
    var description: String {
        return "type:\(chainType) stars:\(stars)"
    }
    
    var hashValue: Int {
        return stars.reduce (0) { $0.hashValue ^ $1.hashValue }
    }
}

func ==(lhs: Chain, rhs: Chain) -> Bool {
    return lhs.stars == rhs.stars
}
