

import UIKit
import MapKit
import Charts
import CoreData

class RunDetailsViewController: UIViewController {
  
  @IBOutlet weak var lineCharView: LineChartView!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var paceLabel: UILabel!
  var run: Run!
  var timeDataSet : [Double] = []
  var distanceDataSet : [Double] = []
  
  let lineChartView = LineChartView()
  var lineChartEntry = [ChartDataEntry]()
  
  
  


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
