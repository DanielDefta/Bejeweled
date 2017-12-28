//
//  MainViewController.swift
//  Bejeweled
//
//  Created by Daniel Defta on 19/12/2017.
//  Copyright © 2017 Daniel Defta. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


class MainViewController: UIViewController {
    
    @IBOutlet weak var selectLevelButton: UIButton!
    @IBOutlet weak var startGame: UIButton!
    
    var startGameCenter: CGPoint!
    var selectLevelCenter: CGPoint!
    
    
    override func viewDidLoad() {
        
        MusicPlayer.sharedInstance.play(name: "Bejeweled 2")
        
        startGameCenter = startGame.center
        selectLevelCenter = selectLevelButton.center
        
        startGame.center.x = -1500
        selectLevelButton.center.x = -1500

        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseOut], animations: {
            self.startGame.center = self.startGameCenter
            self.selectLevelButton.center = self.selectLevelCenter
        }, completion: nil)
        
        UIView.animate(withDuration: 1, delay: 1, options: [], animations: {
            self.startGame.frame.size.width = self.startGame.frame.width * 2
            self.selectLevelButton.frame.size.width = self.selectLevelButton.frame.width * 2

            //self.startGame.frame.size.height = self.startGame.frame.height * 2
            //self.selectLevelButton.frame.size.height = self.selectLevelButton.frame.height * 2
        }, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectLevel" {
            _ = segue.destination as! LevelSelectionViewController
        } else if segue.identifier == "startGame" {
            _ = segue.destination as! GameViewController
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
}
