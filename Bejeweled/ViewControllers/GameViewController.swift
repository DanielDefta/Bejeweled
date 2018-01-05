//
//  GameViewController.swift
//  Bejeweled
//
//  Created by Daniel Defta on 18/12/2017.
//  Copyright © 2017 Daniel Defta. All rights reserved.
//
import RealmSwift
import UIKit
import SpriteKit

import AVFoundation

class GameViewController: UIViewController {
    
    var player: Player!

    var tScore = 0
    var score = 0
    var currentLevelNum = 1
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var totalScore: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    
    @IBOutlet weak var pauseMenu: UIView!
    @IBOutlet weak var volumeSlider: UISlider!
    
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet weak var pauseButtonView: UIView!
    @IBOutlet weak var shuffleButtonView: UIView!
    
    var levelName: String = "Level_0"
    var scene: GameScene!
    var level: Level!
    
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        volumeSlider.value = MusicPlayer.sharedInstance.backgroundMusic.volume
        // Setup view with level 1
        setupLevel(currentLevelNum)
    }
    
    func setupLevel(_ levelNum: Int) {
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        // Setup the level.
        level = Level(filename: "Level_\(levelNum)")
        scene.setLevel(l: level)
        
        scene.addTiles()
        scene.swipeHandler = handleSwipe
        
        //gameOverPanel.hidden = true
        progress.isHidden = true
        shuffleButtonView.isHidden = true
        pauseButtonView.isHidden = true
        pauseMenu.isHidden = true
        
        // Present the scene.
        skView.presentScene(scene)
        
        // Start the game.
        beginGame()
    }

    func beginGame() {
        level.resetComboMultiplier()
        score = 0
        updateLabels()
        scene.animateBeginGame() {
            self.progress.isHidden = false
            self.shuffleButtonView.isHidden = false
            self.pauseButtonView.isHidden = false
        }
        shuffle()
    }
    
    func shuffle() {
        scene.removeAllStarSpritesAnimation {
            self.scene.removeAllStarSprites()
            let newStars = self.level.shuffle()
            self.scene.addSprites(for: newStars)
        }
    }
    
    var swap: Swap!
    func handleSwipe(_ swap: Swap) {
        view.isUserInteractionEnabled = false
        
        if level.isPossibleSwap(swap) {
            level.performSwap(swap: swap)
            //hier controleren of starA speciaal is
            if swap.starA.starType != StarType.speciaal && swap.starB.starType != StarType.speciaal {
                scene.animate(swap: swap,completion: handleMatches)
            } else {
                self.swap = swap
                scene.animate(swap: swap,completion: handleSpecialMatches)
            }
        } else {
            scene.animateInvalidSwap(swap) {
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    func handleMatches() {
        // en hier
        let chains = level.removeMatches(scene)
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        scene.animateMatchedStars(for: chains) {
            
        }
        for chain in chains {
            self.score += chain.score
            self.tScore += chain.score
        }
        self.updateLabels()
        let columns = self.level.fillHoles()
        self.scene.animateFallingStars(columns: columns) {
            let columns = self.level.topUpStars()
            self.scene.animateNewStars(columns) {
                self.handleMatches()
            }
        }
    }
    
    func handleSpecialMatches() {
        // en hier
        let chains = level.removeSpecialMatches(swap, scene)
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        scene.animateMatchedStars(for: chains) {
        }
        for chain in chains {
            self.score += chain.score
            self.tScore += chain.score
        }
        self.updateLabels()
        let columns = self.level.fillHoles()
        self.scene.animateFallingStars(columns: columns) {
            let columns = self.level.topUpStars()
            self.scene.animateNewStars(columns) {
                self.handleMatches()
            }
        }
    }
    
    func beginNextTurn() {
        level.resetComboMultiplier()
        level.detectPossibleSwaps()
        view.isUserInteractionEnabled = true
        checkGameOver()
    }
    
    func updateLabels() {
        if player.highscore < tScore {
            let realm = try! Realm()
            try! realm.write {
                player.highscore = tScore
            }
        }
        targetLabel.text = String(format: "%ld", level.targetScore)
        scoreLabel.text = String(format: "%ld", score)
        totalScore.text = String(format: "%ld", tScore)
        progress.setProgress(Float(score) / Float(level.targetScore), animated: true)
        
        
    }
    
    func checkGameOver() {
        if score >= level.targetScore {
            //gameOverPanel.image = UIImage(named: "LevelComplete")
            currentLevelNum = currentLevelNum < NumLevels ? currentLevelNum+1 : 1
            showGameOver()
        }
    }
    
    func showGameOver() {
        //gameOverPanel.hidden = false
        //pauseMenu.isHidden = false
        progress.isHidden = true
        shuffleButtonView.isHidden = true
        pauseButtonView.isHidden = true
        scene.isUserInteractionEnabled = false
        
        scene.animateGameOver() {
            self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideGameOver))
            self.view.addGestureRecognizer(self.tapGestureRecognizer)
        }
    }
    
    @objc func hideGameOver() {
        view.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
        
        //gameOverPanel.hidden = true
        //pauseMenu.isHidden = true
        scene.isUserInteractionEnabled = true
        
        setupLevel(currentLevelNum)
    }
    @IBAction func shuffleButtonPressed(_ sender: Any) {
        shuffle()
    }
    @IBAction func setVolume(_ sender: UISlider) {
        MusicPlayer.sharedInstance.setVolume(volume: sender.value, tijd: 0.5)
    }
    
    @IBAction func pauseGame(_ sender: Any) {
        shuffleButtonView.isHidden = true
        pauseButtonView.isHidden = true
        scene.isUserInteractionEnabled = false
        
        pauseMenu.isHidden = false
    }
    
    @IBAction func resume(_ sender: Any) {
        shuffleButtonView.isHidden = false
        pauseButtonView.isHidden = false
        pauseMenu.isHidden = true
        scene.isUserInteractionEnabled = true
    }
    
}
