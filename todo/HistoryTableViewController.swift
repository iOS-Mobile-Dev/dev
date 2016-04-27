//
//  HistoryTableViewController.swift
//  todo
//
//  Created by Quyen Castellanos on 3/29/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {
    
    // Class attributes
    private var data:([String],[String]) = ([],[])

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData () {
        var keys = [String]()
        var vals = [String]()
        for date in history.keys {
            if (history[date] as String!).rangeOfString("created") == nil {
                keys.append(date as String!)
                vals.append(history[date] as String!)
            }
        }
        
        self.data.0 = keys
        self.data.1 = vals
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.0.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Create the history cell and populate with data
        let cell = tableView.dequeueReusableCellWithIdentifier("historyCell", forIndexPath: indexPath) as! HistoryTableViewCell
        cell.parentViewController = self
        
        // Populate with general data regardless of tutor vs requestor.
        let parsedData = self.parseData(indexPath.row)
        let role = parsedData["role"]!
        let involvedUser = parsedData["involvedUser"] as String!
        cell.setUser(involvedUser)
        cell.dateLabel.text = parsedData["date"]
        cell.descriptionLabel.text = parsedData["event"]
        cell.dotsLabel.text = parsedData["numDots"]
        getUserPhoto(involvedUser, imageView: cell.userPhoto)
        
        // Do any additional UI modifications accourding to tutor vs requestor.
        if role == "tutor" {
            cell.dotsBg.image = UIImage(named: "GainedDotsBg.png")
        } else if role == "requester" {
            cell.dotsBg.image = UIImage(named: "SpentDotsBg.png")
        }
        
        return cell
    }
    
    func parseData (index:Int) -> Dictionary<String, String> {
        var result: Dictionary<String, String> = ["date" : "", "role" : "", "event" : "", "numDots": "", "involvedUser": ""]
        
        let value = self.data.1[index]
        
        let rangeOfColon = value.rangeOfString(":")
        if rangeOfColon != nil {
            // First separate the role and actual event description into two values.
            let role = value.substringToIndex((rangeOfColon?.startIndex)!)
            result["role"] = role
            let event = value.substringFromIndex((rangeOfColon?.startIndex.advancedBy(2))!)
            result["event"] = event
            
            // Retrieve the other user involved (ie., the tutor or the requestor).
            let eventArr = value.characters.split{$0 == " "}.map(String.init)
            if role == "tutor" {
                result["involvedUser"] = eventArr[3]
            } else if role == "requester" {
                let tutor = eventArr[eventArr.count - 1]
                let name = tutor.substringToIndex(tutor.endIndex.predecessor())
                result["involvedUser"] = name
            }
            
            for item in eventArr {
                let components = item.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
                let part = components.joinWithSeparator("")
                
                if let intVal = Int(part) {
                    result["numDots"] = result["role"] == "tutor" ? ("+\(part)") : ("-\(part)")
                    break
                }
            }
            
        } else {
            result["event"] = value
        }
        
        let dateArr = self.data.0[index].characters.split{$0 == ","}.map(String.init)
        result["date"] = (" \(dateArr[0]), \(dateArr[1])")
        return result
    }
    
    @IBAction func returnToHistoryViewController(segue:UIStoryboardSegue) {
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            self.data.0.removeAtIndex(indexPath.row)
            self.data.1.removeAtIndex(indexPath.row)
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    } */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        print("----------")
        print("Re-entering History")
        self.loadData()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
        
        
        print(history)
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "displayUserProfile" {
            let destVC = segue.destinationViewController as! ProfileViewController
            let user = (sender as! UserPhotoButton).getUser()
            
            destVC.username = user
            destVC.isOwnProfile = false
        }
    }

}
