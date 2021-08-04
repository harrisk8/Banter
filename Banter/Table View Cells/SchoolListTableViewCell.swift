//
//  SchoolListTableViewCell.swift
//  Banter
//
//  Created by Harris Kapoor on 8/4/21.
//  Copyright © 2021 Avidi Industries Inc. All rights reserved.
//

import UIKit

class SchoolListTableViewCell: UITableViewCell {

    @IBOutlet weak var schoolNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
