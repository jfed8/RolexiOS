//
//  SecondViewController.swift
//  Rolex
//
//  Created by J J Feddock on 1/10/19.
//  Copyright © 2019 HF Corporation. All rights reserved.
//

import UIKit
import UserNotifications

class SecondViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    
    @IBOutlet weak var timerLabel: UILabel!
    
    var deviceLocked: Bool = false
    var deviceWasLocked: Bool = false
    var elapsedTime: Int = 0
    var timestamp: TimeInterval = 0
    let center = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        CFNotificationCenterRemoveObserver(CFNotificationCenterGetLocalCenter(),
//                                           Unmanaged.passUnretained(self).toOpaque(),
//                                           nil,
//                                           nil)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [[.alert, .badge]], completionHandler: { (granted, error) in
            // Handle Error
        })
        UNUserNotificationCenter.current().delegate = self
        
        registerforDeviceLockNotification()
    }
    
    func registerforDeviceLockNotification() {
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
    
    private let displayStatusChangedCallback: CFNotificationCallback = { _, cfObserver, cfName, _, _ in
        guard let lockState = cfName?.rawValue as String? else {
            return
        }
        
        let catcher = Unmanaged<SecondViewController>.fromOpaque(UnsafeRawPointer(OpaquePointer(cfObserver)!)).takeUnretainedValue()
        catcher.displayStatusChanged(lockState)
    }
    
    private func displayStatusChanged(_ lockState: String) {
        // the "com.apple.springboard.lockcomplete" notification will always come after the "com.apple.springboard.lockstate" notification
        print("Darwin notification NAME = \(lockState)")
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
    
    
    
    private func startTimer() {
        
        timestamp = NSDate().timeIntervalSince1970
        
        let content = UNMutableNotificationContent()
        content.title = "Hey There"
        content.body = "Keep your phone locked for TONS of points!"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0,
                                                        repeats: false)
        
        let identifier = "UYLLocalNotification"
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request,
                                               withCompletionHandler: { (error) in
                                                // Handle error
        })
        
        print("started timer", timestamp)
    }
    
    private func stopTimer() {
        
        let elapsedTimeDate = NSDate().timeIntervalSince1970 - timestamp
        elapsedTime = Int(elapsedTimeDate)
        
        let alert = UIAlertController(title: "Oh Hey!", message: "Your phone was locked for \(elapsedTime) seconds", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        self.present(alert, animated: true, completion: nil)
        
        deviceLocked = false
        deviceWasLocked = false
        
        timerLabel.text = String(elapsedTime) + " Points"
        
        print("ended timer", timestamp)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }

}

