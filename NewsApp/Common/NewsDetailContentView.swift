//
//  NewsDetailContentView.swift
//  NewsApp
//
//  Created by Microos on 2020/5/1.
//  Copyright © 2020 Yiliang Xie. All rights reserved.
//

import UIKit
import SwiftyJSON
class NewsDetailContentView: UIView {
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var extURLButton: UIButton!

    var extUrl: String!

    @IBAction func extURLButtonAction(_ sender: UIButton) {
        if !extUrl.isEmpty {
            UIApplication.shared.open(URL(string: extUrl)!)
        }
    }

    func applyData(json: JSON) {
        self.titleLabel.text = json["title"].stringValue
        self.sectionLabel.text = json["section"].string ?? "Default Section"
        self.pubDateLabel.text = json["date"].stringValue
        self.contentLabel.setHTML(json["content"].string ?? "..This news has not content..")
        self.contentLabel.numberOfLines = 30
        self.contentLabel.lineBreakMode = .byTruncatingTail
        self.extUrl = json["extUrl"].stringValue

        if self.extUrl.isEmpty {
            self.extURLButton.isEnabled = false
        }


        Helper.asyncLoadImage(imageview: self.newsImageView, urlstr: json["image"].string)

    }

}


extension UITextView {
    func setHTML(_ text: String) {
        do {
            let attributedString: NSAttributedString = try NSAttributedString(
                data: text.data(using: .utf8)!,
                options: [.documentType: NSMutableAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue, .targetTextScaling: 3],
                documentAttributes: nil
            )
            self.attributedText = attributedString
        } catch {
            self.attributedText = nil
            self.text = "Parse HTML with Error, Original Html: \n" + text
        }
    }
}


extension UILabel {
    func setHTML(_ text: String) {
        do {
            let modifiedFont = NSString(format: "<span style=\"font-family: Helvetica; font-size: 15px\">%@</span>" as NSString, text) as String
            let attributedString: NSAttributedString = try NSAttributedString(
                data: modifiedFont.data(using: .utf8)!,
                options: [.documentType: NSMutableAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue, .targetTextScaling: 3],
                documentAttributes: nil
            )
            self.attributedText = attributedString
        } catch {
            self.attributedText = nil
            self.text = "Parse HTML with Error, Original Html: \n" + text
        }
    }
}
