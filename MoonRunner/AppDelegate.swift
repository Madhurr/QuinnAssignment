
import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    UINavigationBar.appearance().tintColor = .white
    UINavigationBar.appearance().barTintColor = .black
    let locationManager = LocationManager.shared
    locationManager.requestWhenInUseAuthorization()
    print("Documents Directory: ", FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last ?? "Not Found!")
    return true
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    CoreDataStack.saveContext()
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    CoreDataStack.saveContext()
  }
  
  
  lazy var persistentContainer: NSPersistentContainer = {
      let container = NSPersistentContainer(name: "MoonRunner")
      container.loadPersistentStores(completionHandler: { (storeDescription, error) in
          if let error = error {

              fatalError("Unresolved error, \((error as NSError).userInfo)")
          }
      })
      return container
  }()
}

