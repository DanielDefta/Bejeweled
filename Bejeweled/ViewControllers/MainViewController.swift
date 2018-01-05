//
//  MainViewController.swift
//  Bejeweled
//
//  Created by Daniel Defta on 19/12/2017.
//  Copyright © 2017 Daniel Defta. All rights reserved.
//

import RealmSwift
import UIKit
import AVFoundation

import GameKit


class MainViewController: UIViewController, GKGameCenterControllerDelegate {
    
    @IBOutlet weak var selectLevelButton: UIButton!
    @IBOutlet weak var startGame: UIButton!
    
    var startGameCenter: CGPoint!
    var selectLevelCenter: CGPoint!
    
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var statsButton: UIButton!
    @IBOutlet weak var instellingenButton: UIButton!
    @IBOutlet weak var trophyButton: UIButton!
    
    
    var player: Player!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startGameCenter = startGame.center
        selectLevelCenter = selectLevelButton.center
        
        
        startGame.center.x = -1500
        selectLevelButton.center.x = -1500
        
        statsButton.alpha = 0
        instellingenButton.alpha = 0
        trophyButton.alpha = 0

        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseOut], animations: {
            self.startGame.center = self.startGameCenter
            self.selectLevelButton.center = self.selectLevelCenter
        }, completion: nil)
        
        UIView.animate(withDuration: 1, delay: 0.5, options: [], animations: {
            self.startGame.frame.size.width = self.startGame.frame.width * 2
            self.selectLevelButton.frame.size.width = self.selectLevelButton.frame.width * 2

            //self.startGame.frame.size.height = self.startGame.frame.height * 2
            //self.selectLevelButton.frame.size.height = self.selectLevelButton.frame.height * 2
        }, completion: nil)
        
        //authPlayer()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectLevel" {
            let levelSelectionViewController = segue.destination as! LevelSelectionViewController
            levelSelectionViewController.player = player
        } else if segue.identifier == "startGame" {
            let gameViewController = segue.destination as! GameViewController
            gameViewController.player = player
        } else if segue.identifier == "showAllPlayersHighscores" {
        } else {
            fatalError("Unknown segue")
        }
        
    }
    
    //@IBAction func unwindFromCampusSelection(_ segue: UIStoryboardSegue){
    //    guard segue.identifier == "didSelectLevel" else {
    //        fatalError("Unknown segue")
    //    }
    //    let levelSelectionViewController = segue.source as! LevelSelectionViewController
    //    //select level en start game
    //    selectedLevel = levelSelectionViewController.selectedLevel
    //}
    
    @IBAction func unwindToRootViewController(segue: UIStoryboardSegue) {
        print("Unwind to Root View Controller")
    }
    
    @IBAction func moreClicked(_ sender: Any) {
        if moreButton.currentImage == #imageLiteral(resourceName: "menu-white") {
            UIView.animate(withDuration: 0.3, animations: {
                self.statsButton.alpha = 1
                self.instellingenButton.alpha = 1
                self.trophyButton.alpha = 1
                })
            moreButton.setImage(UIImage.init(named: "menu-grey"), for: .normal)
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.statsButton.alpha = 0
                self.instellingenButton.alpha = 0
                self.trophyButton.alpha = 0
            })
            moreButton.setImage(UIImage.init(named: "menu-white"), for: .normal)
        }
    }
    
    
    var gcLeaderBoardIdentifier = String()
    
    func authPlayer(){
        let localPlayer = GKLocalPlayer.localPlayer()
        
        
        localPlayer.authenticateHandler = {
            (view, error) in
            
            if view != nil {
                self.present(view!, animated: true, completion: nil)
            }
            else {
                print(GKLocalPlayer.localPlayer().isAuthenticated)
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderBoardIdentifier: String!, error: NSError!)
                    -> Void in
                    if error != nil {
                        print(error)
                    } else {
                        self.gcLeaderBoardIdentifier = leaderBoardIdentifier
                    }
                    } as? (String?, Error?) -> Void)
            }
        }
    }
    
    func saveHighscore(score: Int) {
        
        if GKLocalPlayer.localPlayer().isAuthenticated {
            let scoreReporter = GKScore(leaderboardIdentifier: gcLeaderBoardIdentifier)
            scoreReporter.value = Int64(score)
            
            let scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: nil)
        }
    }
    
    func showLeaderboard(){
        let gcvc = GKGameCenterViewController()
        
        gcvc.gameCenterDelegate = self
        
        self.present(gcvc, animated: true, completion: nil)
    }
    
    @IBAction func showGameCenter(_ sender: Any) {
        showLeaderboard()
    }
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
