

import UIKit
import MapKit
import Charts
import CoreData
class RunDetailsViewController: UIViewController {
  
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var paceLabel: UILabel!
  var run: Run!
  var timeDataSet : [Double] = []
  var durationDataSet : [Double] = []

  override func viewDidLoad() {
    super.viewDidLoad()
     retriveTimeandDistancefromDB()
    }
  
  // Creating NSFetch Request to fetch data from Run db we need y: Distance and x: Time
  func retriveTimeandDistancefromDB (){
    
    // As we know that container is set up in the AppDelegates so we need to refer that container.
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    
    // we need to created a context from the container
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Run")
    
    do {
      let result = try managedContext.fetch(fetchRequest)
      for data in result as! [NSManagedObject]{
        timeDataSet.append(data.value(forKey: "time") as! Double)
        durationDataSet.append(data.value(forKey: "distance") as! Double)
      }
    } catch {
      print("Failed")
    }
    
  }
  
}
