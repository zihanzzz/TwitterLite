//
//  AppDelegate.swift
//  TwiSwift
//
//  Created by James Zhou on 10/26/16.
//  Copyright © 2016 James Zhou. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var storyboard = UIStoryboard(name: "Main", bundle: nil)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLogOut), name: UIConstants.UserEventEnum.didLogout.notification, object: nil)
        
        if User.currentUser != nil {
            // Go to the logged in screen
            
            // let vc = storyboard.instantiateViewController(withIdentifier: "TweetsNavigationViewController") as! UINavigationController
            // let vc = storyboard.instantiateViewController(withIdentifier: "LeftMenuViewController") as! LeftMenuViewController
            let hamburgerViewController = storyboard.instantiateViewController(withIdentifier: "HamburgerViewController") as! HamburgerViewController
            let leftMenuViewController = storyboard.instantiateViewController(withIdentifier: "LeftMenuViewController") as! LeftMenuViewController
            hamburgerViewController.leftMenuViewController = leftMenuViewController
            leftMenuViewController.hamburgerViewController = hamburgerViewController
            
            let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            vc.user = User.currentUser
            
            window?.rootViewController = hamburgerViewController
        }
        
        // back button
        UINavigationBar.appearance().tintColor = UIConstants.twitterPrimaryBlue
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: UIConstants.getTextFontNameLight(), size: 18) as Any], for: .normal)
        
        return true
    }
    
    func userDidLogOut() {
        UIView.animate(withDuration: 0.7, animations: {
            let vc = self.storyboard.instantiateInitialViewController()
            self.window?.rootViewController = vc
        })
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let urlString = "\(url)"
        if urlString.contains("denied") {
            let deniedAlert = UIAlertController(title: "Access Denied", message: "Failed to authenticate with Twitter", preferredStyle: .alert)
            deniedAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(deniedAlert, animated: true, completion: nil)
        } else {
            TwiSwiftClient.sharedInstance?.openURL(url: url)
        }
        return true
    }
}

