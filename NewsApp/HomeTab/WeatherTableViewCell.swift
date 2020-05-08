//
//  WeatherTableViewCell.swift
//  NewsApp
//
//  Created by Microos on 2020/4/28.
//  Copyright © 2020 Yiliang Xie. All rights reserved.
//

import UIKit
import CoreLocation
import os.log
import SwiftyJSON
class WeatherTableViewCell: UITableViewCell {




    //MARK: outlets

    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!

    //MARK: props
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.weatherImage.layer.cornerRadius = UIConfig.cornerRadius

    }

    func applyData(data: [String: String]) {
        self.summaryLabel.text = data["summary"] ?? "N/A"
        self.stateLabel.text = data["state"]
        self.tempLabel.text = data["temp"] ?? "N/A"
        self.cityLabel.text = data["city"] ?? "No Signal"
        self.weatherImage.image = WeatherCellConfig.getImage(summary: data["summary"] ?? "no summary")
    }


}
