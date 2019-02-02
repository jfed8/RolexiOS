//
//  AppDelegate.swift
//  Rolex
//
//  Created by J J Feddock on 1/10/19.
//  Copyright © 2019 JF Corporation. All rights reserved.
//

import UIKit
import Parse
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let center = UNUserNotificationCenter.current()
    var locManager = CLLocationManager()
    var timer = Timer()
    let prefs = UserDefaults.standard
    var currentPoints: Int = 0
    var pointTime: Int = 1
    var elapsedTime: Int = 0
    var currLocked: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let parseConfig = ParseClientConfiguration {
            $0.applicationId = "LocktimeApp8416"
            $0.clientKey = ""
            $0.server = "https://rolex-parse-server.herokuapp.com/parse"
        }
        Parse.initialize(with: parseConfig)
        
        locManager.requestAlwaysAuthorization()
        
        locManager.allowsBackgroundLocationUpdates = true
        
        locManager.pausesLocationUpdatesAutomatically = false
        
        let options: UNAuthorizationOptions = []
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
        application.beginBackgroundTask(withName: "showNotification", expirationHandler: nil)
        
        prefs.set(false, forKey: "ShowMessageBool")
        prefs.synchronize()
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        locManager.startUpdatingLocation()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        locManager.stopUpdatingLocation()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

        prefs.set(nil, forKey: "timestamp")
        prefs.synchronize()
    }

}

