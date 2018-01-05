//
//  StartViewController.swift
//  Bejeweled
//
//  Created by Daniel Defta on 05/01/2018.
//  Copyright © 2018 Daniel Defta. All rights reserved.
//

import RealmSwift
import UIKit

class StartViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playerName: UITextField!
    
    var tap: UITapGestureRecognizer!
    
    var selectedPlayer: Player!
    
    var players: Results<Player>!
    
    override func viewDidLoad() {
        MusicPlayer.sharedInstance.play(name: "Bejeweled 2")
        
        tableView.delegate = self
        tableView.dataSource = self
        players = try! Realm().objects(Player.self).sorted(byKeyPath: "name")
        
        playerName.delegate = self
        
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        playerName.resignFirstResponder()
        tap.cancelsTouchesInView = false
    }
    
    @IBAction func addPlayer(_ sender: Any) {
        voegPlayerToe(name: playerName.text!)
        playerName.text = ""
        playerName.resignFirstResponder()
        tap.cancelsTouchesInView = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        voegPlayerToe(name: textField.text!)
        textField.text = ""
        textField.resignFirstResponder()
        tap.cancelsTouchesInView = false
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tap.cancelsTouchesInView = true
    }
    
    func voegPlayerToe(name: String){
        if name != "" && name.trimmingCharacters(in: .whitespaces) != "" {
            let player = Player(name: name)
            let realm = try! Realm()
            try! realm.write {
                realm.add(player)
            }
            tableView.insertRows(at: [IndexPath(row: players.count - 1, section: 0)], with: .automatic)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMainMenu" {
            let mainViewController = segue.destination as! MainViewController
            mainViewController.player = selectedPlayer
        } else {
            fatalError("Unknown segue")
        }
        
    }
}

extension StartViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (action, view, completionHandler) in
            let player = self.players[indexPath.row]
            let realm = try! Realm()
            try! realm.write {
                realm.delete(player)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedPlayer = players[indexPath.row]
        performSegue(withIdentifier: "showMainMenu", sender: self)
    }
}

extension StartViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell", for: indexPath) as! PlayerCell
        cell.player = players[indexPath.row]
        return cell
    }
}
