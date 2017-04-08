//
//  RedditTableViewCell.swift
//  RedditTopClient
//
//  Created by Siamac 6 on 4/6/17.
//  Copyright © 2017 Siamac6. All rights reserved.
//

import UIKit

class RedditTableViewCell: UITableViewCell {
    @IBOutlet var titleLbl : UILabel!
    @IBOutlet var dateLbl : UILabel!
    @IBOutlet var authorLbl : UILabel!
    @IBOutlet var commentNumLbl : UILabel!
    @IBOutlet var thumbnail : UIImageView!
    @IBOutlet var thumbnailBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLbl.adjustsFontSizeToFitWidth = true
        authorLbl.adjustsFontSizeToFitWidth = true
    }

    @IBAction func clicked(_ sender: UIButton) {
        if let imageURL = sender.layer.value(forKey: "url") {
            NotificationCenter.default.post(name: Notification.Name("notificationID"), object: (imageURL as! String))
        } else {
            NotificationCenter.default.post(name: Notification.Name("notificationID"), object: nil)
        }        
    }

    
        override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)

        // Configure the view for the selected state
    }
    
}
