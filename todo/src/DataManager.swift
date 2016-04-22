//
//  AppSettings.swift
//  todo
//
//  Created by Quyen Castellanos on 3/7/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import Foundation
import Firebase

let concurrentDataAccessQueue = dispatch_queue_create("com.CS378.todo.dataAccessQueue", DISPATCH_QUEUE_CONCURRENT)

// Firebase Refs
let firebaseURL:String = "https://scorching-heat-4336.firebaseio.com"
let rootRef = getFirebase("")
let usersRef = getFirebase("users")
let appSettingsRef = getFirebase("applicationSettings")
let allCoursesRef = getFirebase("allCourses")
let coursesRef = getFirebase("courses")

var tempUserPhoto = UIImage(named:"DefaultProfilePhoto.png")

let registrationFields:[(String, String)] = [("First Name", "John"), ("Last Name", "Appleseed"),  ("Email Address", "jappleseed@gmail.com"), ("Username", "abc123"), ("Password", "password"), ("Major", "Computer Science") , ("Graduation Year", "2016")]
// TODO: We will want this in the database
let lowerDivisionCourses:[String] = ["CS312: Introduction to Programming", "CS314: Data Structures", "CS314H: Data Structures Honors", "CS302: Computer Fluency", "CS105: Computer Programming", "CS311: Discrete Math for Computer Science", "CS311H: Discrete Math for Computer Science: Honors", "CS109: Topics in Computer Science", "CS313E: Elements of Software Design"]

let upperDivisionCourses:[String] = [String]()

var courseDic = Dictionary<String, String>()

var allCourses = Dictionary<String, String>()

var user = Dictionary<String, AnyObject>()

var courses = Dictionary<String, String>()

var notifications = Dictionary<String, String>()

var history = Dictionary<String, String>()

var usersPerCourse = Dictionary<String, String>()

var requester = Dictionary<String, String>()

var paired = Dictionary<String, String>()

let sema: dispatch_semaphore_t = dispatch_semaphore_create(0)

let semaPhoto: dispatch_semaphore_t = dispatch_semaphore_create(0)

var currCourse = ""

var passed = false

var timeCount = 0

var dotsTotal = 1

let burntOranges:[UIColor] = [UIColor.init(red: 186/255, green: 74/255, blue: 0, alpha: 1.0), UIColor.init(red: 214/255, green: 137/255, blue: 16/255, alpha: 1.0), UIColor.init(red: 175/255, green: 96/255, blue: 26/255, alpha: 1.0), UIColor.init(red: 185/255, green: 119/255, blue: 14/255, alpha: 1.0), UIColor.init(red: 110/255, green: 44/255, blue: 0, alpha: 1.0), UIColor.init(red: 120/255, green: 66/255, blue: 18/255, alpha: 1.0)]

func getFirebase(loc: String) -> Firebase! {
    let location = (loc == "" ? firebaseURL : firebaseURL + "/" + loc)
    return Firebase(url:location)
}

func loadAllCourses () {
    dispatch_barrier_async(concurrentDataAccessQueue) {
        if allCourses.isEmpty {
            allCoursesRef.observeEventType(.Value, withBlock: { snapshot in
                allCourses = snapshot.value as! Dictionary<String, String>
                }, withCancelBlock: { error in
                    print(error.description)
            })
        }
    }
}

func updateCourses (courses:[String]) {
    let username = user["Username"] as! String!
    for course in courses {
        let courseArr = course.characters.split{$0 == ":"}.map(String.init)
        let courseNumber = courseArr[0]
        //let item = [username: username]
        let currCourseRef = getFirebase("courses/\(courseNumber)")
        let userCourseRef = currCourseRef.childByAppendingPath(username)
        userCourseRef.setValue(username)
    }
}

func alert (view: AnyObject, description: String, action: UIAlertAction?) {
    let alertController = UIAlertController(title: nil, message: description, preferredStyle: UIAlertControllerStyle.Alert)
    let OKAction = action
    alertController.addAction(OKAction!)
    view.presentViewController(alertController, animated: true, completion:nil)
}

func alertWithPic (view: AnyObject, description: String, action: UIAlertAction, pic: UIImage) {
    let alertController = AlertController(title: nil, message: description, preferredStyle: UIAlertControllerStyle.Alert)
    
    let OKAction = action
    
    let imageView = UIImageView(frame: CGRectMake((alertController.view.bounds.width)/3 - 30, 15, 60, 60))
    imageView.image = pic as UIImage
    
    imageView.layer.cornerRadius = imageView.frame.size.width / 2
    
    alertController.view.addSubview(imageView)
    alertController.addAction(OKAction)
    if !passed {
        alertController.show()
        passed = true
    }
}

func removeObservers(handle: Firebase) {
    handle.removeAllObservers()
}

func createUser(view: AnyObject, inputs: [String: String], courses: [String], segueIdentifier: String) {
    dispatch_barrier_async(concurrentDataAccessQueue) {
        rootRef.createUser(inputs["Email Address"], password: inputs["Password"], withValueCompletionBlock: {
            error, result in
            if error == nil {
                // Insert the user data
                let newUserRef = usersRef.childByAppendingPath(inputs["Username"])
                user = inputs
                user["dots"] = 100
                user["earned"] = 100
                user["paid"] = 0
                
                if courses.count > 0 {
                    for i in 0...courses.count - 1 {
                        courseDic[courses[i].componentsSeparatedByString(":")[0]] = courses[i].componentsSeparatedByString(":")[1]
                    }
                } else {
                    courseDic["dummy"] = ""
                }
                
                user["courses"] = courseDic
                user["requesterUsername"] = ""
                user["requesterPhoto"] = ""
                user["requesterCourse"] = ""
                user["requesterDescription"] = ""
                user["requesterLocation"] = ""
                user["pairedUsername"] = ""
                user["pairedPhoto"] = ""
                user["start"] = ""
                user["finish"] = ""
                user["lastLogin"] = ""
                user["location"] = ""
                user["cancel"] = ""
                newUserRef.setValue(user)
                getFirebase("notifications/").updateChildValues([inputs["Username"]!: ""])
                getFirebase("history/").updateChildValues([inputs["Username"]!: ""])
                updateCourses(courses)
                print("Successfully created user account with username: \(inputs["Username"]!)")
                alert(view, description: "Congrats! You are ready to start using todo.", action: UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                    result in
                    view.performSegueWithIdentifier(segueIdentifier, sender: nil)
                    })
                return
            }
            alert(view, description: "An error has occurred. There may be an existing account for the provided email address.", action: UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        })
    }
}

func modifyEmail(view: AnyObject, originalEmail: String, modifiedEmail: String, password:String) -> Bool{
    var isSuccess:Bool = false
    rootRef.changeEmailForUser(originalEmail, password: password, toNewEmail: modifiedEmail, withCompletionBlock: { error in
        if error != nil {
            print("There is a problem when changed email")
            print(error)
            // There was an error processing the request
            
        } else {
            print("Email changed successfully")
            isSuccess = true
        }
    })
    return isSuccess
}

func modifyPassword(view: AnyObject, oldPassword:String, newPassword:String, userEmail: String) -> Bool{
    var isSuccess:Bool = false
    rootRef.changePasswordForUser(userEmail, fromOld: oldPassword, toNew: newPassword, withCompletionBlock: { error in
        if error != nil {
            print("There is a problem when changed password")
            print(error)
            // There was an error processing the request
        } else {
            print("Password changed successfully")
            isSuccess = true
        }
    })
    return isSuccess
}

func loginUser(view: AnyObject, username: String, password:String, segueIdentifier: String) {
    dispatch_barrier_sync(concurrentDataAccessQueue) {
        let currUserRef = getFirebase("users/" + username)
        user = [:]
        currUserRef.observeEventType(.Value, withBlock: { snapshot in
            if let email = snapshot.value["Email Address"] as? String {
                print("email = \(email)")
                
                // Attempt to log the user in
                rootRef.authUser(email, password: password) {
                    error, authData in
                    if error != nil {
                        print("Unable to login.\nInvalid password.")
                        alert(view, description: "Unable to login. Invalid password.", action: UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        return
                    }
                    
                    user["firstName"] = (snapshot.value["First Name"] as? String)!
                    user["lastName"] = (snapshot.value["Last Name"] as? String)!
                    user["username"] = (snapshot.value["Username"] as? String)!
                    user["password"] = (snapshot.value["Password"] as? String)!
                    user["email"] = (snapshot.value["Email Address"] as? String)!
                    user["major"] = (snapshot.value["Major"] as? String)!
                    user["graduationYear"] = (snapshot.value["Graduation Year"] as? String)!
                    user["photoString"] = (snapshot.value["Photo String"] as? String)!
                    if let _ = snapshot.value["courses"] as? [String: String] {
                        user["courses"] = (snapshot.value["courses"] as? [String: String])!
                    }
                    
                    user["dots"] = (snapshot.value["dots"] as? Int)!
                    user["earned"] = (snapshot.value["earned"] as? Int)!
                    user["paid"] = (snapshot.value["paid"] as? Int)!
                    print("dots are: " + String((user["dots"]! as! Int)))
                    if let _ = snapshot.value["lastLogin"] as? String {
                        user["lastLogin"] = (snapshot.value["lastLogin"] as? String)!
                    }
                    user["requesterUsername"] = ""
                    user["requesterPhoto"] = ""
                    user["requesterCourse"] = ""
                    user["requesterDescription"] = ""
                    user["requesterLocation"] = ""
                    user["pairedUsername"] = ""
                    user["pairedPhoto"] = ""
                    user["start"] = ""
                    user["finish"] = ""
                    user["location"] = ""
                    user["cancel"] = ""
                    
                    requester["username"] = ""
                    requester["photoString"] = ""
                    requester["course"] = ""
                    requester["description"] = ""
                    requester["location"] = ""
                    
                    let notificationUserRef = getFirebase("notifications/" + (user["username"]! as! String))
                    notificationUserRef.observeEventType(.Value, withBlock: { snap in
                        if !(snap.value is NSNull) {
                            notifications = snap.value as! Dictionary
                        }
                    })
                    
                    let historyUserRef = getFirebase("history/" + (user["username"]! as! String))
                    historyUserRef.observeEventType(.Value, withBlock: { snap in
                        if !(snap.value is NSNull) {
                            history = snap.value as! Dictionary
                        }
                    })
                    
                    view.performSegueWithIdentifier(segueIdentifier, sender: nil)
                    removeObservers(notificationUserRef)
                    removeObservers(historyUserRef)
                    removeObservers(currUserRef)
                    dispatch_semaphore_signal(sema)
                }
            } else {
                print("Unable to login. Invalid username.")
                alert(view, description: "Unable to login.\nInvalid username.", action: UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            }
        })
    }
}

func sendRequest (view: AnyObject, askedCourse: String, location:String,  description: String, segueIdentifier: String) {
    let dots = (user["dots"]! as! Int)
    if dotsTotal > dots {
        alert(view, description: "You do not have enough dots to make the request", action: UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        view.performSegueWithIdentifier(segueIdentifier, sender: nil)
        return
    }
    dispatch_barrier_async(concurrentDataAccessQueue) {
        let coursesRef = getFirebase("courses/")
        let askedCourse = askedCourse.componentsSeparatedByString(":")[0]
        currCourse = askedCourse
        coursesRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let _ = snapshot.value[askedCourse] as? Dictionary<String, String> {
                usersPerCourse = snapshot.value[askedCourse] as! Dictionary<String, String>
                for key in usersPerCourse.keys {
                    if key != user["username"] as! String {
                        usersRef.childByAppendingPath(key).updateChildValues(["requesterPhoto": user["photoString"]!])
                        usersRef.childByAppendingPath(key).updateChildValues(["requesterCourse": askedCourse])
                        usersRef.childByAppendingPath(key).updateChildValues(["requesterDescription": description])
                        usersRef.childByAppendingPath(key).updateChildValues(["requesterLocation": location])
                        usersRef.childByAppendingPath(key).updateChildValues(["requesterUsername": user["username"]!])
                    }
                }
                
                view.performSegueWithIdentifier(segueIdentifier, sender: nil)
                
                let notificationUserRef = getFirebase("notifications/" + (user["username"]! as! String))
                let notice = "request: You requested tutoring help in " + askedCourse + "."
                let date = getDateTime()
                notificationUserRef.updateChildValues([date: notice])
                notifications[date] = notice
                return
            }
            alert(view, description: "This course does not exist in our Database.\nPlease enter a valid UT course.", action: UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        })
    }
}

func requestListener(view: AnyObject) {
    dotsTotal = 0
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER)
    dispatch_barrier_sync(concurrentDataAccessQueue) {
        let mainViewController = view as? HomeViewController
        let username = (user["username"] as! String)
        let picString = (user["photoString"] as! String)
        let currUserRef = getFirebase("users/" + username)
        
        currUserRef.observeEventType(.Value, withBlock: { snapshot in
            if snapshot.value["requesterUsername"] as! String != "" {
                if requester["username"] == "" {
                    requester["username"] = (snapshot.value["requesterUsername"] as! String)
                }
                if requester["couse"] == "" {
                    requester["couse"] = (snapshot.value["requesterCourse"] as! String)
                    currCourse = requester["couse"]!
                }
                if requester["photoString"] == "" {
                    requester["photoString"] = (snapshot.value["requesterPhoto"] as! String)
                }
                if requester["description"] == "" {
                    requester["description"] = (snapshot.value["requesterDescription"] as! String)
                }
                if requester["location"] == "" {
                    requester["location"] = (snapshot.value["requesterLocation"] as! String)
                }
            
                let decodedImage = decodeImage(snapshot.value["requesterPhoto"] as! String)
                
                let requesterUserRef = getFirebase("users/" + requester["username"]!)
                
                dispatch_async(dispatch_get_main_queue(), {
                    var notificationUserRef = getFirebase("notifications/" + username)
                    var notice = "singleRequest: " + (snapshot.value["requesterUsername"] as! String) + " is requesting tutoring on:\n" + (snapshot.value["requesterCourse"] as! String) + "\n" + (snapshot.value["requesterDescription"] as! String) + "\nLocation: " + (snapshot.value["requesterLocation"] as! String)
                    let date = getDateTime()
                    notificationUserRef.updateChildValues([date: notice])
                    notifications[date] = notice
                    
                    alertWithPic(view, description: "\n\n\n" + notice, action:
                        UIAlertAction(title: "OK, I will Help", style: UIAlertActionStyle.Default) { result in
                            requesterUserRef.updateChildValues(["pairedUsername": username])
                            requesterUserRef.updateChildValues(["pairedPhoto": picString])
                            
                            notificationUserRef = getFirebase("notifications/" + username)
                            notice = "acceptance: You accepted to help " + (snapshot.value["requesterUsername"] as! String) + " on " + (snapshot.value["requesterCourse"] as! String)
                            
                            let date = getDateTime()
                            notificationUserRef.updateChildValues([date: notice])
                            notifications[date] = notice
                            
                            mainViewController?.tutorContainerView.hidden = false
                            mainViewController?.requestTutoringButton.hidden = true
                            mainViewController!.tutorStudentSwitch.hidden = true
                            mainViewController!.logout.enabled = false
                            
                            mainViewController?.tutorWaitingViewController!.requesterUsername.text = "Waiting for " + requester["username"]! + " to Start the Session"
                            
                            mainViewController?.tutorWaitingViewController!.requesterCourse.text = (snapshot.value["requesterCourse"] as! String)
                            
                            mainViewController?.tutorWaitingViewController!.requesterPhoto.image = decodedImage
                            
                            mainViewController?.tutorSessionViewController!.tutorTutoringSessionUsername.text = "Tutoring Session with " + requester["username"]!
                            
                            mainViewController?.tutorSessionViewController!.tutorTutoringSessionCourse.text = (snapshot.value["requesterCourse"] as! String)
                            
                            mainViewController?.tutorSessionViewController!.tutorTutoringSessionPhoto.image = decodedImage
                            
                        }, pic: decodedImage)
                })
                
                let startRequesterUserRef = getFirebase("users/" + (snapshot.value["requesterUsername"] as! String) + "/" + "start")
                startRequesterUserRef.observeEventType(.Value, withBlock: { snap in
                    if let v_ = snap.value as? String {
                        if v_ == "yes"{
                            let time_ = TimerAndDotsCounter(viewControler: mainViewController!.requesterTutoringSessionViewController!)
                            time_.startCounter()
                            requester["start"] = "yes"
                            mainViewController!.tutorContainerView.hidden = true
                            mainViewController!.tutorSessionContainerView.hidden = false
                            timeCount = 0
                            passed = false
                            removeObservers(currUserRef)
                        }
                    }
                })
                
                let cancelRequesterUserRef = getFirebase("users/" + (snapshot.value["requesterUsername"] as! String) + "/" + "cancel")
                cancelRequesterUserRef.observeEventType(.Value, withBlock: { snap in
                    if let v_ = snap.value as? String {
                        if v_ == "yes" {
                            requester["cancel"] = ""
                            
                            let notificationUserRef = getFirebase("notifications/" + (user["username"]! as! String))
                            let notice = "cancelledSession: " + requester["username"]! + " cancel a tutoring session"
                            let date = getDateTime()
                            notificationUserRef.updateChildValues([date: notice])
                            notifications[date] = notice
                            
                            let username = (user["username"] as! String)
                            let currUserRef = getFirebase("users/" + username)
                            currUserRef.updateChildValues(["requesterPhoto": ""])
                            currUserRef.updateChildValues(["requesterCourse": ""])
                            currUserRef.updateChildValues(["requesterDescription": ""])
                            currUserRef.updateChildValues(["requesterLocation": ""])
                            currUserRef.updateChildValues(["requesterUsername": ""])
                            requesterUserRef.updateChildValues(["cancel": ""])
                            requester["photoString"] = ""
                            requester["course"] = ""
                            requester["description"] = ""
                            requester["location"] = ""
                            requester["username"] = ""
                            requester["start"] = ""
                            removeObservers(rootRef)
                            mainViewController!.tutorStudentSwitch.hidden = false
                            mainViewController!.logout.enabled = true
                            mainViewController!.requestTutoringButton!.hidden = false
                            mainViewController!.blurEffect.hidden = true
                            mainViewController!.requesterContainerView.hidden = true
                            mainViewController!.tutorContainerView.hidden = true
                            mainViewController!.tutorSessionContainerView.hidden = true
                            passed = false
                            removeObservers(currUserRef)
                        }
                    }
                })
            } else {
                if  (snapshot.value["requesterUsername"] as! String) == "" {
                    if let _ = mainViewController?.presentedViewController {
                        view.presentedViewController?!.dismissViewControllerAnimated(false, completion: nil)
                    }
                }
            }
        })
    }
}

func pairedListener(view: AnyObject, askedCourse: String) {
    dispatch_barrier_async(concurrentDataAccessQueue) {
        let mainViewController = view as? HomeViewController
        let username = (user["username"] as! String)
        let currUserRef = getFirebase("users/" + username)
        let askedCourse = askedCourse.componentsSeparatedByString(":")[0]
        currUserRef.observeEventType(.Value, withBlock: { snapshot in
            paired["username"] = snapshot.value.objectForKey("pairedUsername") as? String
            if paired["username"] != "" && (snapshot.value.objectForKey("start") as? String) == "" {
                paired["photoString"] = snapshot.value.objectForKey("pairedPhoto") as? String
                paired["course"] = askedCourse
                
                for key in usersPerCourse.keys {
                    if key != username {
                        usersRef.childByAppendingPath(key).updateChildValues(["requesterPhoto": ""])
                        usersRef.childByAppendingPath(key).updateChildValues(["requesterCourse": ""])
                        usersRef.childByAppendingPath(key).updateChildValues(["requesterDescription": ""])
                        usersRef.childByAppendingPath(key).updateChildValues(["requesterLocation": ""])
                        usersRef.childByAppendingPath(key).updateChildValues(["requesterUsername": ""])
                    }
                }
                
                mainViewController!.blurEffect.hidden = true
                
                mainViewController!.requestTutoringButton.hidden = true
                
                mainViewController!.requesterContainerView.hidden = false
                
                mainViewController!.requesterStartSessionViewController?.tutorUsername.text = paired["username"]! + " is coming to help you on:"
                
                mainViewController!.requesterStartSessionViewController?.tutorCourse.text = paired["course"]
                
                mainViewController!.requesterStartSessionViewController?.tutorPhoto.image = decodeImage(paired["photoString"]!)
                
                mainViewController!.tutorStudentSwitch.hidden = true
                
                mainViewController!.logout.enabled = false
                
                removeObservers(currUserRef)
            }
        })
    }
}

func startSession (mainView: AnyObject, view: AnyObject) {
    var dots = (user["dots"]! as! Int)
    let currUserRef = getFirebase("users/" + (user["username"]! as! String))
    removeObservers(currUserRef)
    let mainViewController = mainView as! HomeViewController
    mainViewController.requesterContainerView.hidden = true
    mainViewController.requesterSessionContainerView.hidden = false
    mainViewController.requesterTutoringSessionViewController!.requesterTutoringSessionTutorUsername.text = "Tutoring Session with " + paired["username"]!
    mainViewController.requesterTutoringSessionViewController!.requesterTutotringSessionCourse.text = paired["course"]
    mainViewController.requesterTutoringSessionViewController!.requesterTutoringSessionTutorPhoto.image = decodeImage(paired["photoString"]!)
    mainViewController.requesterSessionContainerView.hidden = false
    let pairedUserRef = getFirebase("users/" + (paired["username"]! ))
    dispatch_barrier_async(concurrentDataAccessQueue) {
        currUserRef.updateChildValues(["start": "yes"])
        user["start"] = "yes"
        pairedUserRef.observeEventType(.Value, withBlock: { snapshot in
            if (snapshot.value.objectForKey("finish") as? String) != "" || dotsTotal > dots {
                dots = dots - dotsTotal
                user["dots"] = dots
                user["paid"] = (user["paid"] as! Int) + dotsTotal
                
                let notificationUserRef = getFirebase("notifications/" + (user["username"]! as! String))
                let notice = "balanceUpdate: You paid " + String(dotsTotal) + " dots on the tutoring session, your new total is: " + String(dots)
                let date = getDateTime()
                notificationUserRef.updateChildValues([date: notice])
                notifications[date] = notice
                
                let historyUserRef = getFirebase("history/" + (user["username"]! as! String))
                var noticeH = "requester: You spent" + String(dotsTotal) + " dots on tutoring in "
                noticeH = noticeH + paired["course"]! + " from " + paired["username"]!
                
                let dateH = getDateTime()
                historyUserRef.updateChildValues([dateH: noticeH])
                history[dateH] = noticeH
                
                currUserRef.updateChildValues(["pairedPhoto": ""])
                currUserRef.updateChildValues(["pairedCourse": ""])
                currUserRef.updateChildValues(["finish": ""])
                currUserRef.updateChildValues(["start": ""])
                currUserRef.updateChildValues(["pairedUsername": ""])
                currUserRef.updateChildValues(["dots": dots])
                currUserRef.updateChildValues(["paid": (user["paid"] as! Int)])
                pairedUserRef.updateChildValues(["finish": ""])
                paired["photoString"] = ""
                paired["username"] = ""
                paired["course"] = ""
                mainViewController.requesterTutoringSessionViewController!.performSegueWithIdentifier("returnToHomeRequesterSegue", sender: nil)
                mainViewController.requesterSessionContainerView.hidden = true
                removeObservers(pairedUserRef)
            }
        })
    }
}

func cancelSession() {
    dispatch_barrier_async(concurrentDataAccessQueue) {
        let username = (user["username"] as! String)
        let currUserRef = getFirebase("users/" + username)
        currUserRef.updateChildValues(["pairedPhoto": ""])
        currUserRef.updateChildValues(["pairedCourse": ""])
        currUserRef.updateChildValues(["cancel": "yes"])
        currUserRef.updateChildValues(["pairedUsername": ""])
        paired["photoString"] = ""
        paired["username"] = ""
        paired["course"] = ""
        
        let notificationUserRef = getFirebase("notifications/" + (user["username"]! as! String))
        let notice = "cancelledSession: You cancel a tutoring session"
        let date = getDateTime()
        notificationUserRef.updateChildValues([date: notice])
        notifications[date] = notice
    }
}

func finishSession() {
    dispatch_barrier_async(concurrentDataAccessQueue) {
        var dots = (user["dots"]! as! Int)
        dots = dots + dotsTotal
        user["dots"] = dots
        user["earned"] = (user["earned"] as! Int) + dotsTotal
        
        let notificationUserRef = getFirebase("notifications/" + (user["username"]! as! String))
        let notice = "balanceUpdate: You earned " + String(dotsTotal) + " dots on the tutoring session, your new total is: " + String(dots)
        let date = getDateTime()
        notificationUserRef.updateChildValues([date: notice])
        notifications[date] = notice
        
        let username = (user["username"]! as! String)
        
        let historyUserRef = getFirebase("history/" + username)
        var noticeH = "tutor: You tutored " + requester["username"]!
        noticeH = noticeH + " for " + String(dotsTotal) + " dots in " + currCourse + "."
        
        let dateH = getDateTime()
        historyUserRef.updateChildValues([dateH: noticeH])
        history[dateH] = noticeH
        let currUserRef = getFirebase("users/" + username)
        currUserRef.updateChildValues(["dots": dots])
        currUserRef.updateChildValues(["earned": (user["earned"] as! Int)])
        currUserRef.updateChildValues(["finish": "yes"])
        currUserRef.updateChildValues(["start": ""])
        currUserRef.updateChildValues(["requesterPhoto": ""])
        currUserRef.updateChildValues(["requesterCourse": ""])
        currUserRef.updateChildValues(["requesterDescription": ""])
        currUserRef.updateChildValues(["requesterLocation": ""])
        currUserRef.updateChildValues(["requesterUsername": ""])
        requester["photoString"] = ""
        requester["course"] = ""
        requester["description"] = ""
        requester["location"] = ""
        requester["username"] = ""
        requester["start"] = ""
    }
}

func logOutUser () {
    let date = getDateTime()
    user["lastLogin"] = date
    let username = (user["username"] as! String)
    let currUserRef = getFirebase("users/" + username)
    currUserRef.updateChildValues(["lastLogin": date])
    history = Dictionary<String, String>()
    rootRef.unauth()
}

func getDateTime() -> String {
    let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
    return timestamp
}

func decodeImage(stringPhoto: String) -> UIImage {
    
    if stringPhoto == "" || stringPhoto == " " || stringPhoto == "none" {
        return defaultImage()
    }
    
    let imageData = NSData(base64EncodedString: stringPhoto, options: NSDataBase64DecodingOptions(rawValue: 0))
    
    let decodedImage = UIImage(data: imageData!)
    
    return decodedImage!
}

func getUserPhoto(username:String, imageView:UIImageView? = nil) {
    let userRef = getFirebase("users/" + username)
    userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
        if !(snapshot.value is NSNull) {
            let photoString = snapshot.value["Photo String"] as! String
            if imageView != nil {
                imageView!.image = decodePhoto(photoString)
            } else {
                tempUserPhoto = decodePhoto(photoString)
            }
            removeObservers(userRef)
        }
    })
}

func decodePhoto (photoString:String) -> UIImage {
    var decodedImage = UIImage(named: "DefaultProfilePhoto.png")
    
    // If user has selected image other than default image, decode the image
    if photoString.characters.count > 1 {
        let decodedData = NSData(base64EncodedString: photoString, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        decodedImage = UIImage(data: decodedData!)!
    }
    
    return decodedImage!
}

func defaultImage() -> UIImage {
    let size = CGSize(width: 60, height: 60)
    let rect = CGRectMake(0, 0, size.width, size.height)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    UIColor.whiteColor().setFill()
    UIRectFill(rect)
    let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}

private class AlertController: UIAlertController {
    
    private lazy var alertWindow: UIWindow = {
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.rootViewController = ClearViewController()
        window.backgroundColor = UIColor.clearColor()
        return window
    }()
    
    func show(animated flag: Bool = true, completion: (() -> Void)? = nil) {
        if let rootViewController = alertWindow.rootViewController {
            alertWindow.makeKeyAndVisible()
            rootViewController.presentViewController(self, animated: flag, completion: completion)
        }
    }
    
    deinit {
        alertWindow.hidden = true
    }
}

private class ClearViewController: UIViewController {
    
    private override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIApplication.sharedApplication().statusBarStyle
    }
    
    private override func prefersStatusBarHidden() -> Bool {
        return UIApplication.sharedApplication().statusBarHidden
    }
}
