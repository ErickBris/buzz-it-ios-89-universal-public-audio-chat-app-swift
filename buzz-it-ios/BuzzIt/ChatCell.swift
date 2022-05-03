/*-------------------------

- BuzzIt -

created by FV iMAGINATION © 2015
All Rights reserved

-------------------------*/

import UIKit

class ChatCell: UITableViewCell {

    /* Views */
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var playOutlet: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
