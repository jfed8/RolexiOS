//
//  SecondViewController.swift
//  Rolex
//
//  Created by J J Feddock on 1/10/19.
//  Copyright © 2019 JF Corporation. All rights reserved.
//

import UIKit
import Parse
import UserNotifications

class TimerViewController: UIViewController, UNUserNotificationCenterDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    
    var deviceLocked: Bool = false
    var deviceWasLocked: Bool = false
    var elapsedTime: Int = 0
    var timestamp: TimeInterval = 0
    let center = UNUserNotificationCenter.current()
    let prefs = UserDefaults.standard
    var currentPoints: Int = 0
    var pointTime: Int = 1
    var currUser: PFUser = PFUser()
    
    var allowableBounds: Int = 0
    var todaysPoints: Int = 0
    var homeLocation: PFGeoPoint = PFGeoPoint()
    var shouldCount: Bool = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let temp = PFUser.current() {
            currUser = temp
            currUser.fetchInBackground()
        } else {
            dismiss(animated: true, completion: nil)
        }
        
        registerforDeviceLockNotification()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(TimerViewController.getCurrentGroup))
        groupNameLabel.isUserInteractionEnabled = true
        groupNameLabel.addGestureRecognizer(tap)
        
        setCurrentPoints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getCurrentGroup()
        setCurrentPoints()
    }
    
    
    @objc func getCurrentGroup() {
        if currUser["group"] == nil {
            // Get GroupID from Notification
            let alert = UIAlertController(title: "Add a Group", message: "Enter Group ID", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "ex. H23KEcJ7"
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let textField = alert!.textFields![0]
                let query = PFQuery(className:"Group")
                query.whereKey("GroupID", equalTo: textField.text!)
                
                query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                    if error == nil{
                        if let first = objects!.first {
                            self.groupNameLabel.text = first["GroupName"] as? String
                            self.pointTime = (first["pointTime"] as? Int ?? 1)
                            self.allowableBounds = first["AllowedDistance"] as? Int ?? 1
                            self.homeLocation = first["Location"] as? PFGeoPoint ?? PFGeoPoint()
                            
                            self.prefs.set(self.pointTime, forKey: "pointTime")
                        } else {
                            self.groupNameLabel.text = "Group Not Found"
                        }
                    }
                    else {
                        self.groupNameLabel.text = "Group Load Error"
                    }
                })
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            // Use GroupID to get Name from online
            DispatchQueue.global(qos: .background).async {
                do { try self.currUser.fetch() } catch {
                    print("Error on Fetch")
                }
                
                let prefsGroup = self.currUser["group"]
                let query = PFQuery(className:"Group")
                query.whereKey("GroupID", equalTo: prefsGroup)
                
                query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                    if error == nil{
                        if let first = objects!.first {
                            self.pointTime = (first["pointTime"] as? Int ?? 1)
                            self.groupNameLabel.text = first["GroupName"] as? String
                            self.allowableBounds = first["AllowedDistance"] as? Int ?? 1
                            self.homeLocation = first["Location"] as? PFGeoPoint ?? PFGeoPoint()
                            
                            self.prefs.set(self.pointTime, forKey: "pointTime")
                        } else {
                            self.groupNameLabel.text = "Group Not Found"
                        }
                    }
                    else {
                        self.groupNameLabel.text = "Group Load Error"
                    }
                })
            }
        }
    }
    
    func setCurrentPoints() {
        currUser.fetchInBackground {
            (success, error) -> Void in
            if self.currUser["points"] == nil {
                self.currUser["points"] = 0
                self.currUser.saveInBackground()
            }
            
            self.currentPoints = self.currUser["points"] as! Int
            
            self.timerLabel.text = String(self.currentPoints)
            
        }
        
    }
    
    
    
    func showSuccessNotification(msg: String) {

        let alert = UIAlertController(title: "Congrats!", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)

    }
    
    private let displayStatusChangedCallback: CFNotificationCallback = { _, cfObserver, cfName, _, _ in
        guard let lockState = cfName?.rawValue as String? else {
            return
        }

        let catcher = Unmanaged<TimerViewController>.fromOpaque(UnsafeRawPointer(OpaquePointer(cfObserver)!)).takeUnretainedValue()
        catcher.displayStatusChanged(lockState)
    }

    private func displayStatusChanged(_ lockState: String) {
        // the "com.apple.springboard.lockcomplete" notification will always come after the "com.apple.springboard.lockstate" notification
        if (lockState == "com.apple.springboard.lockcomplete") {
            print("DEVICE LOCKED")
            startTimer()
            deviceLocked = true
        } else {
            print("LOCK STATUS CHANGED")
            if (deviceWasLocked) {
                deviceWasLocked = false
                stopTimer()
            }
            if (deviceLocked) {
                deviceWasLocked = true
                deviceLocked = false
            }
        }
    }
    
    func registerforDeviceLockNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [[.alert, .badge]], completionHandler: { (granted, error) in
            // Handle Error
        })
        UNUserNotificationCenter.current().delegate = self

        //Screen lock notifications
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),     //center
            Unmanaged.passUnretained(self).toOpaque(),     // observer
            displayStatusChangedCallback,     // callback
            "com.apple.springboard.lockcomplete" as CFString,     // event name
            nil,     // object
            .deliverImmediately)
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),     //center
            Unmanaged.passUnretained(self).toOpaque(),     // observer
            displayStatusChangedCallback,     // callback
            "com.apple.springboard.lockstate" as CFString,    // event name
            nil,     // object
            .deliverImmediately)
    }
    
    func convertSecondsToString(seconds: Int) -> String {
        var timeString = ""
        var tempSeconds = seconds
        
        // Account for hours, minutes, and seconds
        if (tempSeconds / 86400 > 0) {
            timeString += "\(tempSeconds / 86400) days, "
            tempSeconds = tempSeconds % 86400
        }
        if (tempSeconds / 3600 > 0) {
            timeString += "\(tempSeconds / 3600) hours, "
            tempSeconds = tempSeconds % 3600
        }
        if (tempSeconds / 60 > 0) {
            timeString += "\(tempSeconds / 60) minutes, "
            tempSeconds = tempSeconds % 60
        }
        if (timeString != "") {
            timeString += "and "
        }
        
        timeString += "\(tempSeconds) seconds."
        
        return timeString
    }
    
    
    private func startTimer() {
            timestamp = NSDate().timeIntervalSince1970

            prefs.set(timestamp, forKey: "timestamp")
            prefs.synchronize()
        
            print("started timer", timestamp)
    }
    
    private func stopTimer() {
        if (prefs.object(forKey: "timestamp") != nil) {
            let old_time = prefs.object(forKey: "timestamp") as! TimeInterval
            let elapsedTimeDate = NSDate().timeIntervalSince1970 - old_time
            let rawtime: Int = Int(elapsedTimeDate)

            elapsedTime = rawtime
            
            let additionalPoints: Int = elapsedTime / pointTime
            currentPoints += additionalPoints
            
            let date = Date()
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            
            let today: String = "\(year):\(month):\(day)"
            
            if (prefs.object(forKey: "currDay") != nil && today != prefs.object(forKey: "currDay") as! String) {
                todaysPoints = additionalPoints
                prefs.set(todaysPoints, forKey: "todaysPoints")
                prefs.set(today, forKey: "currDay")
                prefs.synchronize()
            } else {
                todaysPoints = prefs.integer(forKey: "todaysPoints")
                todaysPoints += additionalPoints
                prefs.set(todaysPoints, forKey: "todaysPoints")
                prefs.set(today, forKey: "currDay")
                prefs.synchronize()
            }
            
//            var timeString: String = convertSecondsToString(seconds: rawtime)
            var timeString: String = "Great work!"
            
            timeString += " You have earned \(todaysPoints) points so far today. Keep it up!"

            if elapsedTime > 0 && elapsedTime < 1000000 {
                showSuccessNotification(msg: "\(timeString)")

                timerLabel.text = String(currentPoints)

                currUser["points"] = currentPoints
                currUser.saveInBackground()
            }

            deviceLocked = false
            deviceWasLocked = false

            print("ended timer", timestamp)
        }
    }
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
////
//        completionHandler([.alert, .sound])
//    }
    
    

}
