//
//  DMNewsCard.swift
//  NewsApp
//
//  Created by Microos on 2020/4/28.
//  Copyright © 2020 Yiliang Xie. All rights reserved.
//

import UIKit
import SwiftyJSON





//MARK: data models

class DMNewsCard: NSCoder, NSCoding {
    //MARK: props, basic news card keys
    var artId: String // not base64
    var thumbnailUrl: String?
    var externalUrl: String
    var title: String
    var pubDate: String //ISO 8601
    var pubDateForBookmark: String // e.g. 16 Mar
    var category: String

    //var image: UIImage

    struct PropKeys {
        static let ArtID = "artID"
        static let ThumbnailUrl = "thumbnailUrl"
        static let ExtUrl = "extUrl"
        static let Title = "title"
        static let PubDate = "pubDate"
        static let Category = "category"
        static let PubDateForBookmark = "pubDateForBookmark"
    }

    //MARK: props: computed props
    var computedAge: String {
        get {
            return Helper.computeAgeFromISO8601String(string: self.pubDate)
        }
    }



    init(artId: String, thumbnailUrl: String?, externalUrl: String, title: String, pubDate: String, pubDateForBookmark: String, category: String) {

        self.artId = artId
        self.thumbnailUrl = thumbnailUrl
        self.externalUrl = externalUrl
        self.title = title
        self.pubDate = pubDate
        self.pubDateForBookmark = pubDateForBookmark
        self.category = category

    }

    convenience init(json: JSON) {
        self.init(artId: json["artId"].stringValue, thumbnailUrl: json["thumbnail"].string, externalUrl: json["extUrl"].stringValue, title: json["title"].stringValue,
            pubDate: json["time"].stringValue, pubDateForBookmark: json["timeForBookmark"].stringValue, category: json["section"].stringValue)

    }

    //MARK: encoding
    func encode(with coder: NSCoder) {
        coder.encode(self.artId, forKey: PropKeys.ArtID)
        coder.encode(self.thumbnailUrl, forKey: PropKeys.ThumbnailUrl)
        coder.encode(self.externalUrl, forKey: PropKeys.ExtUrl)
        coder.encode(self.title, forKey: PropKeys.Title)
        coder.encode(self.pubDate, forKey: PropKeys.PubDate)
        coder.encode(self.pubDateForBookmark, forKey: PropKeys.PubDateForBookmark)
        coder.encode(self.category, forKey: PropKeys.Category)

    }

    required convenience init?(coder: NSCoder) {
        let artId = coder.decodeObject(forKey: PropKeys.ArtID) as! String
        let thumbnailUrl = coder.decodeObject(forKey: PropKeys.ThumbnailUrl) as? String
        let extUrl = coder.decodeObject(forKey: PropKeys.ExtUrl) as! String
        let title = coder.decodeObject(forKey: PropKeys.Title) as! String
        let pubDate = coder.decodeObject(forKey: PropKeys.PubDate) as! String
        let pubDateForBookmark = coder.decodeObject(forKey: PropKeys.PubDateForBookmark) as! String
        let category = coder.decodeObject(forKey: PropKeys.Category) as! String

        self.init(artId: artId, thumbnailUrl: thumbnailUrl, externalUrl: extUrl, title: title, pubDate: pubDate, pubDateForBookmark: pubDateForBookmark, category: category)
    }

    func printInfo() {
        print("""
            ----- DMNewsCard -----
            title: \(title)
            secction: \(category)
            ISOtime: \(pubDate)
            localeTime: \(pubDateForBookmark)
            thumbnail: \(thumbnailUrl)
            -------- END ---------
            
            """)
    }

}
