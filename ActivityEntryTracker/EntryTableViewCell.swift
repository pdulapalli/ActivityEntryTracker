//
//  DataTableViewCell.swift
//  ActivityEntryTracker
//
//  Created by Anurag Dulapalli on 12/1/17.
//  Copyright © 2017 Anurag Dulapalli. All rights reserved.
//

import UIKit

class EntryTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }  
}
