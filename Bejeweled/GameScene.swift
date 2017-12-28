//
//  GameScene.swift
//  Bejeweled
//
//  Created by Daniel Defta on 18/12/2017.
//  Copyright © 2017 Daniel Defta. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let invalidSwapSound = SKAction.playSoundFileNamed("Error.wav", waitForCompletion: false)
    
    var level: Level!
    let TileWidth: CGFloat
    let TileHeight: CGFloat
    
    let gameLayer = SKNode()
    let tilesLayer = SKNode()
    let starsLayer = SKNode()
    
    
    private var swipeFromColumn: Int?
    private var swipeFromRow: Int?
    var swipeHandler: ((Swap) -> ())?
    
    var lastUpdateTime = -1.0
    var timeSinceLastCorrectSwipe = 10.0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        
        TileHeight = size.width/9.5;
        TileWidth = TileHeight
        
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        addChild(gameLayer)
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        
        tilesLayer.position = layerPosition
        starsLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        gameLayer.addChild(starsLayer)
        
        gameLayer.isHidden = true
        
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == -1.0{
            lastUpdateTime = currentTime
        }
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        timeSinceLastCorrectSwipe = timeSinceLastCorrectSwipe - deltaTime
        if timeSinceLastCorrectSwipe <= 0 {
            highlitePossibleSwaps(){}
            self.timeSinceLastCorrectSwipe = 2.0
        }
    }
    
    
    func setLevel( l: Level){
        level = l
        let background = SKSpriteNode(imageNamed: level.background)
        background.size = size
        background.zPosition = -1000
        addChild(background)
    }
    
    
    
    
    func addTiles() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if level.tileAt(column: column, row: row) != nil {
                    let tileNode = SKSpriteNode(imageNamed: "Tile")
                    tileNode.size = CGSize(width: TileWidth, height: TileHeight)
                    tileNode.position = pointFor(column: column, row: row)
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }
    func addSprites(for stars: Set<Star>) {
        for star in stars {
            let sprite = SKSpriteNode(imageNamed: star.starType.spriteName)
            sprite.size = CGSize(width: TileWidth, height: TileHeight)
            sprite.position = pointFor(column: star.column, row: star.row)
            starsLayer.addChild(sprite)
            star.sprite = sprite
            
            
            
            sprite.alpha = 0
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 0.5, withRange: 0.5),
                    SKAction.group([
                        SKAction.fadeIn(withDuration: 0.25),
                        SKAction.scale(to: 1.0, duration: 0.25)
                        ])
                    ]))
        }
    }
    
    func removeAllStarSpritesAnimation(completion: @escaping () -> ()) {
        for child in starsLayer.children {
            child.run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 0.2, withRange: 0.3),
                    SKAction.group([
                        SKAction.fadeOut(withDuration: 0.25),
                        SKAction.scale(to: 0.0, duration: 0.25)])
                    ]))
        }
        if starsLayer.children.count == 0 {
            run(SKAction.wait(forDuration: 0), completion: completion)
        }
        else {
            run(SKAction.wait(forDuration: 1), completion: completion)
        }
    }
    
    func removeAllStarSprites(){
        starsLayer.removeAllChildren()
    }
    
    func pointFor(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
            return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1
        guard let touch = touches.first else { return }
        let location = touch.location(in: starsLayer)
        // 2
        let (success, column, row) = convertPoint(point: location)
        if success {
            // 3
            if level.starAt(column: column, row: row) != nil {
                // 4
                swipeFromColumn = column
                swipeFromRow = row
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1
        guard swipeFromColumn != nil else { return }
        
        // 2
        guard let touch = touches.first else { return }
        let location = touch.location(in: starsLayer)
        
        let (success, column, row) = convertPoint(point: location)
        if success {
            
            // 3
            var horzDelta = 0, vertDelta = 0
            if column < swipeFromColumn! {          // swipe left
                horzDelta = -1
            } else if column > swipeFromColumn! {   // swipe right
                horzDelta = 1
            } else if row < swipeFromRow! {         // swipe down
                vertDelta = -1
            } else if row > swipeFromRow! {         // swipe up
                vertDelta = 1
            }
            
            // 4
            if horzDelta != 0 || vertDelta != 0 {
                trySwap(horizontal: horzDelta, vertical: vertDelta)
                
                // 5
                swipeFromColumn = nil
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    func trySwap(horizontal horzDelta: Int, vertical vertDelta: Int) {
        // 1
        let toColumn = swipeFromColumn! + horzDelta
        let toRow = swipeFromRow! + vertDelta
        // 2
        guard toColumn >= 0 && toColumn < NumColumns else { return }
        guard toRow >= 0 && toRow < NumRows else { return }
        // 3
        if let toStar = level.starAt(column: toColumn, row: toRow),
            let fromStar = level.starAt(column: swipeFromColumn!, row: swipeFromRow!) {
            // 4
            //print("*** swapping \(fromStar) with \(toStar)")
            if let handler = swipeHandler {
                let swap = Swap(starA: fromStar, starB: toStar)
                handler(swap)
            }
        }
    }
    
    func animate(swap: Swap, completion: @escaping () -> ()) {
        let spriteA = swap.starA.sprite!
        let spriteB = swap.starB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let duration: TimeInterval = 0.3
        
        let moveA = SKAction.move(to: spriteB.position, duration: duration)
        moveA.timingMode = .easeOut
        spriteA.run(moveA, completion: completion)
        
        let moveB = SKAction.move(to: spriteA.position, duration: duration)
        moveB.timingMode = .easeOut
        spriteB.run(moveB)
        
        timeSinceLastCorrectSwipe = 10.0
    }
    
    func animateInvalidSwap(_ swap: Swap, completion: @escaping () -> ()) {
        let spriteA = swap.starA.sprite!
        let spriteB = swap.starB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let duration: TimeInterval = 0.2
        
        let moveA = SKAction.move(to: spriteB.position, duration: duration)
        moveA.timingMode = .easeOut
        
        let moveB = SKAction.move(to: spriteA.position, duration: duration)
        moveB.timingMode = .easeOut
        
        spriteA.run(SKAction.sequence([moveA, moveB]), completion: completion)
        spriteB.run(SKAction.sequence([moveB, moveA]))
        
        run(invalidSwapSound)
    }
    
    func animateMatchedStars(for chains: Set<Chain>, completion: @escaping () -> ()) {
        for chain in chains {
            animateScore(for: chain)
            for star in chain.stars {
                if let sprite = star.sprite {
                    if sprite.action(forKey: "removing") == nil {
                        let scaleAction = SKAction.scale(to: 0.1, duration: 0.3)
                        scaleAction.timingMode = .easeOut
                        sprite.run(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
                                   withKey:"removing")
                    }
                }
            }
        }
        run(SKAction.wait(forDuration: 0.3), completion: completion)
    }
    
    func animateFallingStars(columns: [[Star]], completion: @escaping () -> ()) {
        // 1
        var longestDuration: TimeInterval = 0
        for array in columns {
            for (idx, star) in array.enumerated() {
                let newPosition = pointFor(column: star.column, row: star.row)
                // 2
                let delay = 0.1*TimeInterval(idx)
                // 3
                let sprite = star.sprite!   // sprite always exists at this point
                let duration = TimeInterval(((sprite.position.y - newPosition.y) / TileHeight) * 0.1)
                // 4
                longestDuration = max(longestDuration, duration + delay)
                // 5
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.run(
                    SKAction.sequence([
                        SKAction.wait(forDuration: delay),
                        SKAction.group([moveAction])]))
            }
        }
        
        // 6
        run(SKAction.wait(forDuration: longestDuration), completion: completion)
    }
    
    func animateNewStars(_ columns: [[Star]], completion: @escaping () -> ()) {
        // 1
        var longestDuration: TimeInterval = 0
        
        for array in columns {
            // 2
            let startRow = array[0].row + 1
            
            for (idx, star) in array.enumerated() {
                // 3
                let sprite = SKSpriteNode(imageNamed: star.starType.spriteName)
                sprite.size = CGSize(width: TileWidth, height: TileHeight)
                sprite.position = pointFor(column: star.column, row: startRow)
                starsLayer.addChild(sprite)
                star.sprite = sprite
                // 4
                let delay = 0.2 * TimeInterval(array.count - idx - 1)
                // 5
                let duration = TimeInterval(startRow - star.row) * 0.1
                longestDuration = max(longestDuration, duration + delay)
                // 6
                let newPosition = pointFor(column: star.column, row: star.row)
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.alpha = 0
                sprite.run(
                    SKAction.sequence([
                        SKAction.wait(forDuration: delay),
                        SKAction.group([
                            SKAction.fadeIn(withDuration: 0.05),
                            moveAction
                            ])
                        ]))
            }
        }
        // 7
        run(SKAction.wait(forDuration: longestDuration), completion: completion)
    }
    
    func addSpriteForStar(star: Star){
        let sprite = SKSpriteNode(imageNamed: star.starType.spriteName)
        sprite.size = CGSize(width: TileWidth, height: TileHeight)
        sprite.position = pointFor(column: star.column, row: star.row)
        starsLayer.addChild(sprite)
        star.sprite = sprite
    }
    
    func animateScore(for chain: Chain) {
        // Figure out what the midpoint of the chain is.
        let firstSprite = chain.firstStar().sprite!
        let lastSprite = chain.lastStar().sprite!
        let centerPosition = CGPoint(
            x: (firstSprite.position.x + lastSprite.position.x)/2,
            y: (firstSprite.position.y + lastSprite.position.y)/2 - 8)
        
        // Add a label for the score that slowly floats up.
        let scoreLabel = SKLabelNode(fontNamed: "Gill Sans UltraBold")
        scoreLabel.fontSize = 17
        scoreLabel.text = String(format: "%ld", chain.score)
        scoreLabel.position = centerPosition
        scoreLabel.zPosition = 300
        starsLayer.addChild(scoreLabel)
        
        let moveAction = SKAction.move(by: CGVector(dx: 0, dy: 5), duration: 0.3)
        let fadeAction = SKAction.fadeOut(withDuration: 0.3)
        moveAction.timingMode = .easeOut
        fadeAction.timingMode = .easeOut
        scoreLabel.run(SKAction.sequence([moveAction, fadeAction, SKAction.removeFromParent()]))
    }
    
    
    func animateGameOver(_ completion: @escaping () -> ()) {
        let action = SKAction.move(by: CGVector(dx: 0, dy: -size.height), duration: 0.3)
        action.timingMode = .easeIn
        gameLayer.run(action, completion: completion)
    }
    
    func animateBeginGame(_ completion: @escaping () -> ()) {
        gameLayer.isHidden = false
        gameLayer.yScale = 0
        let action = SKAction.scaleY(to: 1.0, duration: 0.5)
        action.timingMode = .easeOut
        gameLayer.run(action, completion: completion)
    }
    
    
    func highlitePossibleSwaps(completion: @escaping () -> ()) {
        let spriteA =  level.possibleSwaps.first?.starA.sprite!
        let spriteB =  level.possibleSwaps.first?.starB.sprite!
        
        let pulseUp = SKAction.scale(to: 1.1, duration: 0.2)
        let pulseDown = SKAction.scale(to: 1, duration: 0.2)
        pulseUp.timingMode = .easeOut
        pulseDown.timingMode = .easeOut
        
        spriteA?.run(SKAction.sequence([pulseUp, pulseDown,pulseUp, pulseDown,pulseUp, pulseDown]), completion: completion)
        spriteB?.run(SKAction.sequence([pulseUp, pulseDown,pulseUp, pulseDown,pulseUp, pulseDown]), completion: completion)
    }
}
