//
//  LevelSelectionViewController.swift
//  Bejeweled
//
//  Created by Daniel Defta on 19/12/2017.
//  Copyright © 2017 Daniel Defta. All rights reserved.
//

import Foundation
import UIKit

class LevelSelectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var levelsCollectionView: UICollectionView!
    
    /*
     Stores the selection so the presenting view controller can read it after the unwind segue.
     This is an implicitly unwrapped optional because it starts out nil but should never be nil
     when it is read (as the unwind segue is triggered by a selection).
     */
    var selectedLevel: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.levelsCollectionView.delegate = self
        self.levelsCollectionView.dataSource = self

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "levelCell", for: indexPath) as! LevelCollectionViewCell
        let text = indexPath.row + 1
        cell.levelNumber.text = NSString(format: "%d", text) as String
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedLevel = indexPath.row+1
        performSegue(withIdentifier: "startLevel", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startLevel" {
            let gameViewController = segue.destination as! GameViewController
            gameViewController.currentLevelNum = selectedLevel
        } else {
            fatalError("Unknown segue")
        }
    }
}

