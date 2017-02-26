//
//  AppDelegate.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-01-28.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let userDefaults = Foundation.UserDefaults.standard
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FIRApp.configure()  // fcm notification configure

        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(tokenRefreshNotification(notification:)),
                                               name: NSNotification.Name.firInstanceIDTokenRefresh,
                                               object: nil)
        
        // iOS 10 support
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        }
            
        else {
            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }
        
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        FIRMessaging.messaging().disconnect()   // disconnect from FCM
        print("Disconnecting from firebase cloud messaging.")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        self.connectToFcm() // when the application becomes active, we want to connect to firebase
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        let deviceTokenString = deviceToken.map{ String(format: "%02X", $0) }.joined()
        userDefaults.set( deviceTokenString , forKey: "device_token")
        // Print it to console
        print("APNs device token: \(deviceTokenString)")
        
        // Persist it in your backend in case it's new
    }
    
    // Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
        print("APNs registration failed: \(error)")
    }
    
//    // Push notification received
//    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
//        // Print notification payload data
//        print("Push notification received: \(data)")
//    }
    
    // Push notification received from fcm
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> ()) {
        
        print("Message ID \(userInfo["gcm.message_id"]!)")
        print(userInfo)
    }
    
    
    //MARK: Custom Firebase Code
    
    func tokenRefreshNotification(notification: NSNotification) {
        let refreshedToken = FIRInstanceID.instanceID().token()!
        print("InstanceID token: \(refreshedToken)")
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    // Connect to FCM
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
   

}

