import CoreData
import UIKit

@UIApplicationMain
  class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "DataModel")
    container.loadPersistentStores(completionHandler: {
      storeDescription, error in
      if let error = error {
        fatalError("Could load data store: \(error)")
      }
    })
    return container
  }()
  
  lazy var managedObjectContext: NSManagedObjectContext = persistentContainer.viewContext
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    // Calls color customized UIelements
    customizeAppearance()
    
    // code from page 642
    let tabController = window!.rootViewController as! UITabBarController
    
    if let tabViewControllers = tabController.viewControllers {
      // First tab
      var navController = tabViewControllers[0]
                    as! UINavigationController
      let controller1 = navController.viewControllers.first
                    as! CurrentLocationViewController
      controller1.managedObjectContext = managedObjectContext
      // Second tab
      navController = tabViewControllers[1]
                      as! UINavigationController
      let controller2 = navController.viewControllers.first
                      as! LocationsViewController
      controller2.managedObjectContext = managedObjectContext
      let _ = controller2.view // p.683 Tämän pitäisi estää appsin kaatuminen vanhemmissa IOS:issa, mutta voi olla että on tarpeeton?
      
      // Third tab p.695
      navController = tabViewControllers[2] as! UINavigationController
      let controller3 = navController.viewControllers.first
                        as! MapViewController
      controller3.managedObjectContext = managedObjectContext
    }
    print(applicationDocumentsDirectory)
    listenForFatalCoreDataNotifications() // p.658
    return true
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

  // MARK: - Helper methods
  func listenForFatalCoreDataNotifications() {
    // 1
    NotificationCenter.default.addObserver(forName: CoreDataSaveFailedNotification,
                                           object: nil, queue: OperationQueue.main,
                                           using: { notification in
                                            // 2
                                            let message = """
                                            There was a fatal error in the app and it cannot continue.
                                            Press OK to terminate the app. Sorry for the inconvenience.
                                            """
                                            // 3
                                            let alert = UIAlertController(
                                              title: "Internal Error", message: message, preferredStyle: .alert)
                                            
                                            // 4
                                            let action = UIAlertAction(title: "OK", style: .default) { _ in
                                              
                                              let expection = NSException(
                                                name: NSExceptionName.internalInconsistencyException,
                                                reason: "Fatal Core Data error", userInfo: nil)
                                              expection.raise()
                                            }
                                            alert.addAction(action)
                                            
                                            // 5
                                            let tabController = self.window!.rootViewController!
                                            tabController.present(alert, animated: true, completion: nil)
    })
  }
  
  // Customize App UI with custom colours
  func customizeAppearance() {
    UINavigationBar.appearance().barTintColor = UIColor.black
    UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white ]
    
    UITabBar.appearance().barTintColor = UIColor.black
    
    let tintColor = UIColor(red: 255/255.0, green: 118/255.0,
                            blue: 88/255.0, alpha: 1.0)
    UITabBar.appearance().tintColor = tintColor
  }
}

