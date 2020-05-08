//
//  SimpleTableViewCell.swift
//  NewsApp
//
//  Created by Microos on 2020/5/1.
//  Copyright © 2020 Yiliang Xie. All rights reserved.
//

import UIKit

class SimpleTableViewCell: UITableViewCell {

    

    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
