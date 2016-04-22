//
//  SettingTableViewController.swift
//  todo
//
//  Created by Kiu Lam on 4/21/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {
    @IBOutlet weak var lbl_username: UITableViewCell!
    @IBOutlet weak var lbl_password: UITableViewCell!
    @IBOutlet weak var lbl_email: UITableViewCell!
    
    let givenUser:String = (user["username"] as? String)!
    var givenPassword:String = (user["password"] as? String)!
    
    var givenEmail:String = (user["email"] as? String)!

    override func viewDidLoad() {
        super.viewDidLoad()
        lbl_username.detailTextLabel?.text = user["username"]! as? String
        lbl_email.detailTextLabel?.text = user["email"] as? String
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 6
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        switch cell?.reuseIdentifier!{
        case "username"? :
            promptChangeInfo("username",info: givenUser)
            
        case "password"?:
            promptChangeInfo("password",info: givenPassword)
            
            
        case "email"?:
            promptChangeInfo("email",info: givenEmail)
            
        default:
            print("neither")
        }
        
    }
    
    /** Change info would display an alertview prompting user to enter new information **/
    private func promptChangeInfo(section:String,info:String){
        var tField: UITextField!
        
        func configurationTextField(textField: UITextField!)
        {
            switch section{
                case "username":
                    textField.placeholder = user["username"] as? String
                    break;
                case "password":
                    textField.placeholder = "No seriously! I am not going to display the password"
                    break;
                case "email":
                    textField.placeholder = user["email"] as? String
                    break;
            default:
                print("neither")
            }
            tField = textField
        }
        func handleCancel(alertView: UIAlertAction!)
        {
        }
        
        let alert = UIAlertController(title: "Enter Input", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
            switch section{
                case "username":
                    /**  TODO: Modify username  **/
                    
                    break;
                case "password":
                    if(modifyPassword(self, oldPassword: self.givenPassword, newPassword: tField.text!, userEmail: self.givenEmail)){
                        print("In success")
                        
                        //Update info
                        user["password"] = tField.text!
                        print(user["password"])
                        self.givenPassword = (user["password"] as? String)!
                    }
                    break;
                case "email":
                    if(modifyEmail(self, originalEmail: self.givenEmail, modifiedEmail: tField.text!, password: self.givenPassword)){
                        
                        //Update Info
                        user["email"] = tField.text!
                        self.givenEmail = (user["email"] as? String)!
                    }
                    break;
                
            default:
                print("neither")
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil))
        self.presentViewController(alert, animated: true, completion: {

        })
        
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
