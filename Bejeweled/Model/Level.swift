//
//  Level.swift
//  Bejeweled
//
//  Created by Daniel Defta on 18/12/2017.
//  Copyright © 2017 Daniel Defta. All rights reserved.
//

import Foundation

let NumColumns = 9
let NumRows = 9
let NumLevels = 20

class Level {
    var background = "Background"
    var targetScore = 0
    var possibleSwaps = Set<Swap>()
    
    var specialSwap: Swap!
    
    private var comboMultiplier = 0
    
    fileprivate var stars = Array2D<Star>(columns: NumColumns, rows: NumRows)
    
    func starAt(column: Int, row: Int) -> Star? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return stars[column, row]
    }
    
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    
    func tileAt(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
    func shuffle() -> Set<Star> {
        var set: Set<Star>
        repeat {
            set = createInitialStars()
            detectPossibleSwaps()
            print("possible swaps: \(possibleSwaps)")
        } while possibleSwaps.count == 0
        
        return set
    }
    
    private func createInitialStars() -> Set<Star> {
        var set = Set<Star>()
        
        // 1
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if tiles[column, row] != nil {
                    // 2
                    var starType: StarType
                    repeat {
                        starType = StarType.random()
                    } while (starType == StarType.speciaal ||
                        column >= 2 &&
                        stars[column - 1, row]?.starType == starType &&
                        stars[column - 2, row]?.starType == starType)
                        || (row >= 2 &&
                            stars[column, row - 1]?.starType == starType &&
                            stars[column, row - 2]?.starType == starType)
                
                    // 3
                    let star = Star(column: column, row: row, starType: starType)
                    stars[column, row] = star
                
                    // 4
                    set.insert(star)
                }
            }
        }
        return set
    }
    
    init(filename: String) {
        // 1
        guard let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename: filename) else { return }
        // 2
        
        guard let tilesArray = dictionary["tiles"] as? [[Int]] else { return }

        // 3
        for (row, rowArray) in tilesArray.enumerated() {
            // 4
            let tileRow = NumRows - row - 1
            // 5
            for (column, value) in rowArray.enumerated() {
                if value == 1 {
                    tiles[column, tileRow] = Tile()
                }
            }
        }
        
        guard let b = dictionary["background"] as? String else { return }
        background = b
        targetScore = dictionary["targetScore"] as! Int
    }
    
    func performSwap(swap: Swap){
        let columnA = swap.starA.column
        let rowA = swap.starA.row
        let columnB = swap.starB.column
        let rowB = swap.starB.row
        
        stars[columnA, rowA] = swap.starB
        swap.starB.column = columnA
        swap.starB.row = rowA
        
        stars[columnB, rowB] = swap.starA
        swap.starA.column = columnB
        swap.starA.row = rowB
        swap.starA.inserted = true
        
    }
    
    func detectPossibleSwaps() -> Bool {
        var set = Set<Swap>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let star = stars[column, row] {
                    
                    // TODO: detection logic goes here
                    if column < NumColumns - 1 {
                        // Have a star in this spot? If there is no tile, there is no star.
                        if let other = stars[column + 1, row] {
                            // Swap them
                            stars[column, row] = other
                            stars[column + 1, row] = star
                            
                            // Is either star now part of a chain?
                            if hasChainAt(column: column + 1, row: row) ||
                                hasChainAt(column: column, row: row) {
                                set.insert(Swap(starA: star, starB: other))
                            }
                            
                            // Swap them back
                            stars[column, row] = star
                            stars[column + 1, row] = other
                        }
                    }
                    
                    if row < NumRows - 1 {
                        if let other = stars[column, row + 1] {
                            stars[column, row] = other
                            stars[column, row + 1] = star
                            
                            // Is either star now part of a chain?
                            if hasChainAt(column: column, row: row + 1) ||
                                hasChainAt(column: column, row: row) {
                                set.insert(Swap(starA: star, starB: other))
                            }
                            
                            // Swap them back
                            stars[column, row] = star
                            stars[column, row + 1] = other
                        }
                    }
                }
            }
        }
        
        possibleSwaps = set
        
        if( possibleSwaps.count == 0) {
            return false
        } else {
            return true
        }
    }
    
    func isPossibleSwap(_ swap: Swap) -> Bool {
        return possibleSwaps.contains(swap)
    }
    
    private func hasChainAt(column: Int, row: Int) -> Bool {
        let starType = stars[column, row]!.starType
        
        if starType == StarType.speciaal {
            return true
        }
        // Horizontal chain check
        var horzLength = 1
        
        // Left
        var i = column - 1
        while i >= 0 && stars[i, row]?.starType == starType {
            i -= 1
            horzLength += 1
        }
        
        // Right
        i = column + 1
        while i < NumColumns && stars[i, row]?.starType == starType {
            i += 1
            horzLength += 1
        }
        if horzLength >= 3 { return true }
        
        // Vertical chain check
        var vertLength = 1
        
        // Down
        i = row - 1
        while i >= 0 && stars[column, i]?.starType == starType {
            i -= 1
            vertLength += 1
        }
        
        // Up
        i = row + 1
        while i < NumRows && stars[column, i]?.starType == starType {
            i += 1
            vertLength += 1
        }
        return vertLength >= 3
    }
    
    //nog zorgen dat alles gebeurd zonder de scene door te geven
    func removeMatches(_ scene: GameScene) -> Set<Chain> {
        let horizontalChains = detectHorizontalMatches()
        let verticalChains = detectVerticalMatches()
        
        removeStars(horizontalChains, scene)
        removeStars(verticalChains, scene)
        
        calculateScores(for: horizontalChains)
        calculateScores(for: verticalChains)
        
        return horizontalChains.union(verticalChains)
    }
    
    func removeSpecialMatches(_ swap: Swap, _ scene: GameScene) -> Set<Chain> {
        let chains = detectSpecialMatches(swap)
        removeStars(chains, scene)
        
        calculateScores(for: chains)
        
        return chains
    }
    
    //nog zorgen dat alles gebeurd zonder de scene door te geven
    private func removeStars(_ chains: Set<Chain>,_ scene: GameScene) {
        for chain in chains {
            if chain.stars.count == 5 {
                for star in chain.stars {
                    if star.inserted == false {
                        stars[star.column, star.row] = nil
                    }
                    else {
                        let star = Star(column: star.column, row: star.row, starType: StarType.speciaal)
                        stars[star.column, star.row] = star
                        scene.addSpriteForStar(star: star) // ------------>hier
                    }
                }
            }else {
                for star in chain.stars {
                    stars[star.column, star.row] = nil
                }
            }
            
        }
    }
    
    private func detectSpecialMatches(_ swap: Swap) -> Set<Chain> {
        let chain = Chain(chainType: .speciaal)
        var star: Star!
        if swap.starA.starType != StarType.speciaal {
            star = swap.starA
            chain.add(star: swap.starB)
        } else {
            star = swap.starB
            chain.add(star: swap.starA)
        }
        // 1
        var set = Set<Chain>()
        // 2
        for row in 0..<NumRows {
            var column = 0
            while column < NumColumns {
                // 3
                if let star1 = stars[column, row] {
                    let matchType = star1.starType
                    // 4
                    if matchType == star.starType {
                        chain.add(star: star1)
                    }
                }
                // 6
                column += 1
            }
        }
        set.insert(chain)
        return set
    }
    
    private func detectHorizontalMatches() -> Set<Chain> {
        // 1
        var set = Set<Chain>()
        // 2
        for row in 0..<NumRows {
            var column = 0
            while column < NumColumns-2 {
                // 3
                if let star = stars[column, row] {
                    let matchType = star.starType
                    // 4
                    if stars[column + 1, row]?.starType == matchType &&
                        stars[column + 2, row]?.starType == matchType {
                        // 5
                        let chain = Chain(chainType: .horizontal)
                        repeat {
                            chain.add(star: stars[column, row]!)
                            column += 1
                        } while column < NumColumns && stars[column, row]?.starType == matchType
                        set.insert(chain)
                        continue
                    }
                }
                // 6
                column += 1
            }
        }
        return set
    }
    
    private func detectVerticalMatches() -> Set<Chain> {
        var set = Set<Chain>()
        
        for column in 0..<NumColumns {
            var row = 0
            while row < NumRows-2 {
                if let star = stars[column, row] {
                    let matchType = star.starType
                    
                    if stars[column, row + 1]?.starType == matchType &&
                        stars[column, row + 2]?.starType == matchType {
                        let chain = Chain(chainType: .vertical)
                        repeat {
                            chain.add(star: stars[column, row]!)
                            row += 1
                        } while row < NumRows && stars[column, row]?.starType == matchType
                        
                        set.insert(chain)
                        continue
                    }
                }
                row += 1
            }
        }
        return set
    }
    
    func fillHoles() -> [[Star]] {
        var columns = [[Star]]()
        // 1
        for column in 0..<NumColumns {
            var array = [Star]()
            for row in 0..<NumRows {
                // 2
                if tiles[column, row] != nil && stars[column, row] == nil {
                    // 3
                    for lookup in (row + 1)..<NumRows {
                        if let star = stars[column, lookup] {
                            // 4
                            stars[column, lookup] = nil
                            stars[column, row] = star
                            star.row = row
                            // 5
                            array.append(star)
                            // 6
                            break
                        }
                    }
                }
            }
            // 7
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    func topUpStars() -> [[Star]] {
        var columns = [[Star]]()
        var starType: StarType = .unknown
        
        for column in 0..<NumColumns {
            var array = [Star]()
            
            // 1
            var row = NumRows - 1
            while row >= 0 && stars[column, row] == nil {
                // 2
                if tiles[column, row] != nil {
                    // 3
                    var newStarType: StarType
                    repeat {
                        newStarType = StarType.random()
                    } while newStarType == starType || newStarType == StarType.speciaal
                    starType = newStarType
                    // 4
                    let star = Star(column: column, row: row, starType: starType)
                    stars[column, row] = star
                    array.append(star)
                }
                
                row -= 1
            }
            // 5
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    private func calculateScores(for chains: Set<Chain>) {
        // orange => 5
        // yellow => 14
        // red => 30
        // purple => 60
        // green => 100
        // blue => 200
        // white => 365
        
        for chain in chains {
            chain.score = 60 * (chain.length - 2) * comboMultiplier
            comboMultiplier += 1
        }
    }
    
    func resetComboMultiplier() {
        comboMultiplier = 1
    }
}
