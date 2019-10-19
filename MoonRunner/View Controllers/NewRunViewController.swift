import UIKit
import CoreData
import CoreLocation
import CoreMotion
class NewRunViewController: UIViewController {
  // y: axis Distance and x: axis as Time
  @IBOutlet weak var launchPromptStackView: UIStackView!
  @IBOutlet weak var dataStackView: UIStackView!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var stopButton: UIButton!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var paceLabel: UILabel!
  
  @IBOutlet weak var xaxisLabel: UILabel!
  
  @IBOutlet weak var yaxisLabel: UILabel!
  
  @IBOutlet weak var zaxisLabel: UILabel!
  private var run: Run?
  private var locationManager = LocationManager.shared
  private var seconds = 0
  private var timer : Timer?
  private var distance = Measurement(value: 0, unit: UnitLength.meters)
  private var locationList : [CLLocation] = []
  var speedtoStoreInDb : Double = 0
  
  var motion = CMMotionManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dataStackView.isHidden = true
    myAccelerometer()
  }
  
  func myAccelerometer(){
    motion.accelerometerUpdateInterval = 0.5
    motion.startAccelerometerUpdates(to: OperationQueue.current!) { (data , error) in
      print(data as Any)
      if let trueData = data {
        self.view.reloadInputViews()
        let x = trueData.acceleration.x
        let y = trueData.acceleration.y
        let z = trueData.acceleration.z
        self.xaxisLabel.text = " x: \(Double(x).rounded(toPlcaes: 3))"
        self.yaxisLabel.text = " y: \(Double(y).rounded(toPlcaes: 3))"
        self.zaxisLabel.text = " z: \(Double(z).rounded(toPlcaes: 3))"
      }
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    timer?.invalidate()
    locationManager.stopUpdatingLocation()
  }
  
  @IBAction func startTapped() {
    startRun()
  }
  
  @IBAction func stopTapped() {
    let alertController = UIAlertController(title: "End Run?", message: "Do you wish to end Run ?", preferredStyle: .actionSheet)
    alertController.addAction(UIAlertAction(title: "cancel", style: .cancel))
    alertController.addAction(UIAlertAction(title: "Save", style: .default) { _ in
      self.stopRun()
      self.saveRun()
      self.performSegue(withIdentifier: .details, sender: nil)
    })
    alertController.addAction(UIAlertAction(title: "Discard", style: .destructive) { _ in
      self.stopRun()
      _ = self.navigationController?.popViewController(animated: true)
    })
    present(alertController , animated: true)
  }
  
  private func startRun(){
    launchPromptStackView.isHidden = true
    dataStackView.isHidden = false
    startButton.isHidden = true
    stopButton.isHidden = false
    seconds = 0
    distance = Measurement(value: 0, unit: UnitLength.meters)
    locationList.removeAll()
    updateDisplay()
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
      self.eachSecond()
    }
    startLocationUpdates()
  }
  
  private func stopRun(){
    launchPromptStackView.isHidden = false
    dataStackView.isHidden = true
    startButton.isHidden = false
    stopButton.isHidden = true
    locationManager.stopUpdatingLocation()
  }
  
  func eachSecond(){
    seconds += 1
    updateDisplay()
  }
  
  private func updateDisplay(){
    let formattedDistance = FormatDisplay.distance(distance)
    let formattedTime = FormatDisplay.time(seconds)
    let formattedPace = FormatDisplay.pace(distance: distance, seconds: seconds, outputUnit: UnitSpeed.kilometersPerHour)
    distanceLabel.text = "Distance:  \(formattedDistance)"
    timeLabel.text = "Time:  \(formattedTime)"
    paceLabel.text = "Pace:  \(formattedPace)"
    // Some time cause optional unwrapping force unraping
    // fixed using guard let !!
    guard let speedtoStoreInDb = Double(formattedPace.split(separator: " ")[0]) else { return  }
    let storeSpeeddb = Run(context: CoreDataStack.context)
    storeSpeeddb.speed = speedtoStoreInDb
    storeSpeeddb.time = Double(seconds)/3600
    guard let distancetoStoreInDb = Double(formattedDistance.split(separator: " ")[0]) else { return }
    storeSpeeddb.distance = distancetoStoreInDb 
  }
  
  private func startLocationUpdates(){
    locationManager.delegate = self
    // Todo for our purpose we can use .automotive
    locationManager.activityType = .automotiveNavigation
    locationManager.distanceFilter = 10
    locationManager.startUpdatingLocation()
  }
  
// Saving data inside Core Data
  
  private func saveRun(){
    let newRun = Run(context: CoreDataStack.context)
    newRun.duration = Int16(seconds)
    newRun.timestamp = Date()
    for location in locationList{
      let locationObject = Location(context: CoreDataStack.context)
      locationObject.timestamp = location.timestamp
      locationObject.latitude = location.coordinate.latitude
      locationObject.longitude = location.coordinate.longitude
      newRun.addToLocations(locationObject)
    }
    
    CoreDataStack.saveContext()
    run = newRun
  }
  
}
extension NewRunViewController: SegueHandlerType {
  enum SegueIdentifier: String {
    case details = "RunDetailsViewController"
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segueIdentifier(for: segue) {
    case .details:
      let destination = segue.destination as! RunDetailsViewController
      destination.run = run
    }
  }
}
// This Delegation method will be called each time Core Location updates the user's location providing an array of CLLocation objects. Usully this array contains only one object but if there are more, they are orderd by time with the most recent location last

// A CLLocataion contains some great information including the latitude , longitude and timestamp of the reading.

// Before blindly accepting the reading, its worth checkong the accuracy if the data. If the device isn't confident it has a reading within 20 meters of the user's actual location, its best to keep it out of your dataset . it also important  to ensure that the data is recent.

extension NewRunViewController: CLLocationManagerDelegate{
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    for newLocation in locations{
      let howRecent = newLocation.timestamp.timeIntervalSinceNow
      guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else{ continue }
      
      if let lastLocation = locationList.last {
        let delta = newLocation.distance(from: lastLocation)
        distance = distance + Measurement(value: delta , unit: UnitLength.meters)
      }
      locationList.append(newLocation)
    }
  }
}


extension Double {
  func rounded(toPlcaes places: Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return (self * divisor).rounded() / divisor
  }
}
