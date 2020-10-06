//
//  InboxTableCell.swift
//  Mesh
//
//  Created by Harris Kapoor on 10/6/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit

class InboxTableCell: UITableViewCell {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
