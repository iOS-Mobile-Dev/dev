//
//  RequesterStartSessionViewController.swift
//  todo
//
//  Created by Nelma Perera on 3/22/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class RequesterStartSessionViewController: UIViewController {
    
    @IBOutlet weak var tutorPhoto: UIImageView!
    
    @IBOutlet weak var tutorUsername: UILabel!
    
    @IBOutlet weak var tutorCourse: UILabel!
    
    var mainViewController: HomeViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func startSessionButton(sender: AnyObject) {
        startSession(mainViewController!, view: self)
        time_ = TimerAndDotsCounter(viewControler: self.mainViewController!.requesterTutoringSessionViewController!)
        
        if !timer.valid {
            time_!.startCounter()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? HomeViewController {
            self.mainViewController = vc
        }
    }
}
