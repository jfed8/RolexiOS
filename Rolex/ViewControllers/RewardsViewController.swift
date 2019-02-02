//
//  FirstViewController.swift
//  Rolex
//
//  Created by J J Feddock on 1/10/19.
//  Copyright © 2019 JF Corporation. All rights reserved.
//

import UIKit
import Parse

class RewardsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var rewardsTable: UITableView!
    
    var rewardsList: [PFObject] = []
    var currUser: PFUser = PFUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let temp = PFUser.current() {
            currUser = temp
        } else {
            dismiss(animated: true, completion: nil)
        }
        
        rewardsTable.separatorStyle = .none
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        loadRewards()
    }
    
    func loadRewards() {
        let currGroup = PFUser.current()!["group"]
        let query = PFQuery(className:"Rewards")
        query.whereKey("groupID", equalTo: currGroup)
        
        query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
            if error == nil{
                self.rewardsList = objects!
                print(self.rewardsList)
                self.rewardsTable.reloadData()
            }
            else {
                print(error?.localizedDescription)
            }
        })
        
    }
    

    // --- MARK: Table View ---
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rewardsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RewardTableViewCell = rewardsTable.dequeueReusableCell(withIdentifier: "RewardCell") as! RewardTableViewCell

        cell.mainBackground.layer.cornerRadius = 8
        cell.mainBackground.layer.masksToBounds = true
        
        cell.titleLabel.text = rewardsList[indexPath.row]["rewardTitle"] as? String ?? "No Title"
        cell.costLabel.text = rewardsList[indexPath.row]["rewardValue"] as? String ?? "No Cost"
        cell.costLabel.text = cell.costLabel.text! + " Points"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cost = Int(rewardsList[indexPath.row]["rewardValue"] as! String)!
        let name = rewardsList[indexPath.row]["rewardTitle"]!
        let points = currUser["points"] as! Int
        
        if (points >= cost) {
            let alert = UIAlertController(title: "Redeem", message: "Are you sure you want to redeem \(cost) points for \(String(describing: name))? If so, make sure you Group Lead is watching when you press OK", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let alert2 = UIAlertController(title: "Congrats!", message: "You have redeemed \(cost) points for \(String(describing: name)).", preferredStyle: .alert)
                alert2.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert2, animated: true, completion: nil)
                self.currUser["points"] = points - cost
                self.currUser.saveInBackground()
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert2 = UIAlertController(title: "Not Quite", message: "You tried to redeem \(cost) points for \(String(describing: name)), but you only have \(points). Keep your phone locked to get more!", preferredStyle: .alert)
            alert2.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert2, animated: true, completion: nil)
        }
        
        rewardsTable.deselectRow(at: indexPath, animated: true)
    }
    

}

