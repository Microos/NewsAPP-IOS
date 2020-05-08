//
//  NewsDetailViewController.swift
//  NewsApp
//
//  Created by Microos on 2020/5/1.
//  Copyright © 2020 Yiliang Xie. All rights reserved.
//

import UIKit
import SwiftSpinner
import SwiftyJSON


class NewsDetailViewController: UIViewController {

    private var newsCardData: DMNewsCard?

    var articleBookmarked = false
    var bookmarkChanged = false // if changed, notify table view to reload
    var json: JSON?
    var bookmarkReceiverId: String!


    @IBOutlet weak var barBookmarkItem: UIBarButtonItem!

    func applyData(data: DMNewsCard, id: String) {
        self.newsCardData = data
        self.bookmarkReceiverId = id
        BookmarkManager.registerAsNotificationReceiver(id: self.bookmarkReceiverId, receiver: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        if newsCardData != nil, json == nil {
            SwiftSpinner.show("Loading Detailed Artcile", animated: true)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if let cardData = self.newsCardData, json == nil {
            //start loading
            GuardianAPI.requestArticleData(artID: cardData.artId, completion: {
                result in

                switch result {
                case .success(let json):
                    self.navigationItem.title = json["title"].stringValue
                    self.json = json
                    let contentView = self.view.viewWithTag(1) as! NewsDetailContentView
                    contentView.applyData(json: json)
                    SwiftSpinner.hide()
                case .failure(let error):
                    SwiftSpinner.hide()
                    self.view.makeToast("Error: \(error)")
                }
            })

            // init bookmark
            let marked = BookmarkManager.isMarked(artId: cardData.artId)
            self.articleBookmarked = marked
            self.changeBookmarkBtnState(to: marked)

        }
    }



    @IBAction func barBookmarkItemAction(_ sender: UIBarButtonItem) {
        self.articleBookmarked = !self.articleBookmarked
        self.changeBookmarkBtnState(to: self.articleBookmarked)
        self.updateBookmarkDB(to: self.articleBookmarked)
    }
    @IBAction func barTwitterItemAction(_ sender: UIBarButtonItem) {
        if let json = self.json, !json["extUrl"].stringValue.isEmpty {
            Helper.openTwitterShareInSafari(link: json["extUrl"].stringValue)
        } else {
            warningToast("Warning: This news doesn't have an external link to share!")
        }

    }

    @IBAction func barExitItemAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
        BookmarkManager.unregisterAsNotificationReceiver(id: self.bookmarkReceiverId)
    }

}

extension NewsDetailViewController: BookmarkManagerDataChangeNotificationReceiver {
    func bookmarkManagerDataChangezNotified() {
        let marked = BookmarkManager.isMarked(artId: self.newsCardData!.artId)
        self.articleBookmarked = marked
        self.changeBookmarkBtnState(to: marked)
    }
    func changeBookmarkBtnState(to: Bool) {
        if to {
            //set to true, add bookmark
            self.barBookmarkItem.image = BookmarkButtonUIConfig.imageMarked
        } else {
            //set to false, remove bookmark
            self.barBookmarkItem.image = BookmarkButtonUIConfig.imageUnmarked
        }
    }
    private func updateBookmarkDB(to: Bool) {
        self.bookmarkChanged = true
        if to {
            //set to true, add bookmark
            BookmarkManager.addBookmark(item: newsCardData)
            self.view.makeToast("Article Bookmarked. Check out the Bookmarks tab to view", duration: 2.0, position: .bottom)

        } else {
            //set to false, remove bookmark
            BookmarkManager.removeBookmark(artId: newsCardData?.artId)
            self.view.makeToast("Article removed from Bookmarks", duration: 2.0, position: .bottom)
        }
    }
}
