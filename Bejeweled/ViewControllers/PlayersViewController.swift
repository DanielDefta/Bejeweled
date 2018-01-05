//
//  PlayersViewController.swift
//  Bejeweled
//
//  Created by Daniel Defta on 05/01/2018.
//  Copyright © 2018 Daniel Defta. All rights reserved.
//

import RealmSwift
import UIKit

class PlayersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var players: Results<Player>!
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        players = try! Realm().objects(Player.self).sorted(byKeyPath: "highscore", ascending: false)
    }
    
}

extension PlayersViewController: UITableViewDelegate {
    
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
}

extension PlayersViewController: UITableViewDataSource{
    
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
