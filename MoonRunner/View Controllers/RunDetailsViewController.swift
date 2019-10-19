

import UIKit
import MapKit
import Charts
import CoreData

class RunDetailsViewController: UIViewController {
  
  @IBOutlet weak var lineCharView: LineChartView!
  @IBOutlet var tableView: UITableView!
  var run: Run!
  var timeDataSet : [Double] = []
  var distanceDataSet : [Double] = []
  var speedDataSet : [Double] = []
  let lineChartView = LineChartView()
  var lineChartEntry = [ChartDataEntry]()
  
  
  var coreDataStack: CoreDataStack!
  var fetchController : NSFetchedResultsController<NSFetchRequestResult>!
  


  override func viewDidLoad() {
    super.viewDidLoad()
     retriveTimeandDistancefromDB()
     addDataSettoChart(timedataSet: timeDataSet, distancedataSet: distanceDataSet)
    

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
        distanceDataSet.append(data.value(forKey: "distance") as! Double)
        speedDataSet.append(data.value(forKey: "speed") as! Double)
      }
    } catch {
      print("Failed")
    }
    
  }
  
  func addDataSettoChart(timedataSet : [Double] , distancedataSet : [Double]){
    lineCharView.backgroundColor = UIColor.white
    for i in 0..<timedataSet.count{
      let value = ChartDataEntry(x: Double(i) , y: distanceDataSet[i])
      lineChartEntry.append(value)
    }
    let chartDataSet = LineChartDataSet(entries: lineChartEntry , label: "Speed")
    let chartData = LineChartData()
    chartData.addDataSet(chartDataSet)
    chartData.setDrawValues(true)
    chartDataSet.colors = [UIColor.systemPink]
    chartDataSet.setCircleColor(UIColor.systemPink)
    chartDataSet.circleHoleColor = UIColor.systemPink
    chartDataSet.circleRadius = 4.0
    
    
    //Gradiant fill
    let gradiantColors = [UIColor.systemPink.cgColor , UIColor.clear.cgColor] as CFArray
    let colorLocations: [CGFloat] = [1.0 , 0.0]
    guard let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradiantColors, locations: colorLocations) else { print ("gradient error"); return}
    chartDataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
    chartDataSet.drawFilledEnabled = true
    
    //Axes setup
    lineCharView.data =  chartData
  }
  
}
extension RunDetailsViewController: UITableViewDataSource {
    
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return speedDataSet.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SpeedTableViewCell.reuseIdentifier, for: indexPath) as? SpeedTableViewCell else {
            fatalError("Unexpected Index Path")
        }

        // Configure Cell
      cell.speedLabel.text = String(speedDataSet[indexPath.row]) + "kmph"
   
      
        return cell
    }
  

}
