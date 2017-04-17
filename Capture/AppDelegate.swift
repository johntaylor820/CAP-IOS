    //
//  AppDelegate.swift
//  CAPTURE
//
//  Created by The CAPTURE Team.
//  Copyright © 2016 Josh Hill. All rights reserved.
//  52.90.110.93

import UIKit
import CoreData
import Alamofire
import Fabric
import Crashlytics
import FBSDKLoginKit
import ReachabilitySwift
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var reachability:Reachability!
    let kTokenKey = "tokenIsSet"
    var netWorkNotificationView:NetworkNotificationView!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Fabric.with([Crashlytics.self])
//        Twitter.sharedInstance().start(withConsumerKey: "fz2N0I308i271ZYUSw4tow9zA", consumerSecret: "jM2BrDd6mGYU3BHlgZWKDnlbI0CwnuD1esZ0H6DTdSiguWHfjS")
        Fabric.with([Twitter.self()])

        // Override point for customization after application launch.
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 20)!,
            NSForegroundColorAttributeName: UIColor(red: 68/255, green: 68/255, blue: 68/255, alpha: 1.0)
        ]
        UINavigationBar.appearance().tintColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        
        let memoryCapacity = 500 * 1024 * 1024
        let diskCapacity = 500 * 1024 * 1024
        let urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath:"captureDish")
        URLCache.shared = urlCache
        
        UserManager.sharedInstance.currentAuthorizedUser { (user) in
            if let _ = user {
                self.navigateToApplication()
            } else {
                let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore_capture")
                if launchedBefore  {
                    self.navigateToLogin(false)
                } else {
                    UserDefaults.standard.set(true, forKey: "launchedBefore_capture")
                    self.navigateToIntro()
                }
            }
        }
        Fabric.with([Crashlytics.self, Twitter.self])
        reachability = Reachability()

        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.reachabilityChanged(_:)),name: ReachabilityChangedNotification,object: reachability)
        do{
            try reachability?.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        return true
        //return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func reachabilityChanged(_ notification: Notification) {
        if netWorkNotificationView == nil {
            let widht = UIScreen.main.bounds.width
            DispatchQueue.main.async(execute: {
                self.netWorkNotificationView = NetworkNotificationView(frame: CGRect(x: 8, y: 0, width: widht-16, height: 64))
                self.netWorkNotificationView.translatesAutoresizingMaskIntoConstraints = false
            })
        }
        if self.reachability.isReachableViaWiFi || self.reachability.isReachableViaWWAN {
            if netWorkNotificationView != nil {
                netWorkNotificationView.removeFromSuperview()
            }
        } else {
            let vc = topViewController()
            if let vc = vc {
                vc.view.addSubview(netWorkNotificationView)
                let top = NSLayoutConstraint(item: vc.topLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: netWorkNotificationView, attribute: .top, multiplier: 1.0, constant: 100)
                let leading = NSLayoutConstraint(item: netWorkNotificationView, attribute: .leading, relatedBy: .equal, toItem: vc.view, attribute: .leading, multiplier: 1.0, constant: 8)
                let trailing = NSLayoutConstraint(item: vc.view, attribute: .trailing, relatedBy: .equal, toItem: netWorkNotificationView, attribute: .trailing, multiplier: 1.0, constant: 8)
                let height = NSLayoutConstraint(item: netWorkNotificationView, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1.0, constant: 64)
                netWorkNotificationView.addConstraint(height)
                vc.view.addConstraints([top, leading, trailing])
                vc.view.layoutIfNeeded()
                top.constant = 4
                UIView.animate(withDuration: 0.2, animations: {
                    vc.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        
//        if Twitter.sharedInstance().application(app, open:url, options: options) {
//            return true
//        }

        return FBSDKApplicationDelegate.sharedInstance().application(app,
                                                                     open: url,
                                                                     sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String,
                                                                     annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    @available(iOS, introduced: 8.0, deprecated: 9.0)
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
//        if Twitter.sharedInstance().application(app, open:url, options: options) {
//            return true
//        }

        return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                     open: url,
                                                                     sourceApplication: sourceApplication!,
                                                                     annotation: annotation)
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        
        //FBSDKAppEvents.activateApp()
    }
    // MARK: - Navigation
    
    func navigateToIntro() {
        DispatchQueue.main.async(execute: {
            let storyboard = UIStoryboard(name: "Intro", bundle: nil)
            let introVC = storyboard.instantiateViewController(withIdentifier: "IntroVc")
            self.window?.rootViewController = introVC
        })
    }
    
    func navigateToApplication() {
        DispatchQueue.main.async(execute: {
            let application = UIApplication.shared
            self.registerForPushNotifications(application)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainTabBar = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
            self.window?.rootViewController = mainTabBar
        })
    }
    
    func navigateToLogin(_ animated: Bool) {
        DispatchQueue.main.async(execute: {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC") as! UINavigationController
            if animated {
                self.window?.rootViewController?.present(loginVC, animated: true, completion: nil)
            } else {
                self.window?.rootViewController = loginVC
            }
        })
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: reachability)
    }

    // MARK: - Push notifications
    func registerForPushNotifications(_ application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        debugPrint("received push notification: \(userInfo)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("failed to register for push notification: \( error.localizedDescription )")
    }
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != UIUserNotificationType() {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let characterSet: CharacterSet = CharacterSet( charactersIn: "<>" )
        
        let deviceTokenString = deviceToken.description
            .trimmingCharacters(in: characterSet)
            .replacingOccurrences(of: " ", with: "")
        
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: kTokenKey) {
            if token != deviceTokenString {
                setDeviceToken(deviceTokenString)
            }
        } else {
            setDeviceToken(deviceTokenString)
        }
    }
    func setDeviceToken(_ token: String) {
        //let defaults = NSUserDefaults.standardUserDefaults()
        // TODO
        /*UserManager.sharedInstance.registerDeviceToken(token, completion: { success, error in
            guard success && error == nil else {
                debugPrint(error)
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                defaults.setObject(token, forKey: self.kTokenKey)
                debugPrint("Received device token: \( token )")
            })
        })*/
    }
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.xxxx.ProjectName" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Capture", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Capture.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }

}

