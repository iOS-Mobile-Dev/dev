//
//  RequestHelpViewController.swift
//  todo
//
//  Created by Nelma Perera on 3/15/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class RequestHelpViewController: UIViewController, UITableViewDelegate, UIPopoverPresentationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, CourseSelectionProtocol {
    
    var data = lowerDivisionCourses
    
    var filterData = [String]()
    
    var coursesListViewController: CoursesListView? = nil
    
    @IBOutlet weak var coursesDropDown: UIButton!
    
    @IBOutlet weak var editedDropDown: UITextField!
    
    @IBOutlet weak var locationText: UITextField!
    
    @IBOutlet weak var descriptionText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.editedDropDown.delegate = self
        self.locationText.delegate = self
        self.descriptionText.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editedDropDown(sender: UITextField) {
        coursesDropDownList(sender)
    }
    
    @IBAction func coursesDropDownList(sender: UITextField) {
        
        allCoursesRef.observeEventType(.Value, withBlock: { snapshot in
            allCourses = snapshot.value as! Dictionary<String, String>
            if sender.text! == "" {
                self.data = self.toStringArrayFrom(allCourses)
                self.filterData = self.data
            } else {
                for i in 0...self.data.count - 1 {
                    if self.data[i].rangeOfString(sender.text!) != nil || self.data[i].lowercaseString.rangeOfString(sender.text!) != nil {
                        self.filterData.append(self.data[i])
                    }
                }
            }
            self.presentPopover(sourceController: self, sourceView: self.coursesDropDown, sourceRect: CGRectMake(0, self.coursesDropDown.bounds.height + 1, self.coursesDropDown.bounds.width, 200))
                }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    func toStringArrayFrom(dict:Dictionary<String,String>) -> [String]{
        
        var result:[String] = []
        for key in dict{
            result.append(key.0 + ": " + key.1)
        }
        
        
        return result
    }
    
    func presentPopover(sourceController sourceController:UIViewController, sourceView:UIView, sourceRect:CGRect) {
        // Create the view controller we want to display as the popup.
        
        if self.coursesListViewController != nil {
            self.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
        }
        
        self.coursesListViewController = CoursesListView(title: "Courses List", preferredContentSize: CGSize(width: self.coursesDropDown.bounds.width, height: 200))
        
        self.coursesListViewController!.mainController = self
        
        let popoverShowViewController = coursesListViewController!.popoverPresentationController
        
        // Cause the views to be created in this view controller. Gets them added to the view hierarchy.
        //self.coursesListViewController.view
        coursesListViewController!.tableView.layoutIfNeeded()
        
        coursesListViewController!.courses = filterData
        
        // Set attributes for the popover controller.
        // Notice we're get an existing object from the view controller we want to popup!
        popoverShowViewController?.permittedArrowDirections = UIPopoverArrowDirection()
        popoverShowViewController?.delegate = self
        popoverShowViewController?.sourceView = sourceView
        popoverShowViewController?.sourceRect = sourceRect
                
        // Show the popup.
        // Notice we are presenting form a view controller passed in. We need to present from a view controller
        // that has views that are already in the view hierarchy.
        sourceController.presentViewController(coursesListViewController!, animated: true, completion: nil)
    }
    
    func selectedCourse (course: String) {
        self.editedDropDown.text = course
    }
    
    func endFiltering (force: Bool) {
        self.view.endEditing(force)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "lookingTutors" {
            sendRequest(self, askedCourse: self.editedDropDown.text!.uppercaseString, location: self.locationText.text!, description: descriptionText.text!, segueIdentifier: identifier)
        }
        return false
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Indicate we want the same presentation behavior on both iPhone and iPad.
        return UIModalPresentationStyle.None
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}
