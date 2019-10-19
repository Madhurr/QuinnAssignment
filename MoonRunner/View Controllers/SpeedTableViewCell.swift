
import UIKit

class SpeedTableViewCell: UITableViewCell {
  
  
    //Mark: Properties
    static let reuseIdentifier = "QuoteCell"

  @IBOutlet weak var constantSpeedLabel: UILabel!
  @IBOutlet weak var speedLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
