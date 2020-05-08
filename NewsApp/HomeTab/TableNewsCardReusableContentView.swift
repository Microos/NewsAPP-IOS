//
//  TableNewsCardReusableContentView.swift
//  NewsApp
//
//  Created by Microos on 2020/5/2.
//  Copyright © 2020 Yiliang Xie. All rights reserved.
//

import UIKit
import SDWebImage
class TableNewsCardReusableContentView: UIView {
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var cateLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!

    //MARK: props
    var toastDelegate: ToastDelegate?
    private var data: DMNewsCard?
    private var articleBookmarked: Bool = false

    @IBAction func bookmarkButton(_ sender: Any) {
        self.toggleBookmark()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        let viewFromXib = Bundle.main.loadNibNamed("TableNewsCardReusableContentView", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        self.addSubview(viewFromXib)

        // UI setup radius, boarder color/width
        viewFromXib.layer.backgroundColor = #colorLiteral(red: 0.9180614352, green: 0.9216353297, blue: 0.9249114394, alpha: 1)
        viewFromXib.layer.cornerRadius = UIConfig.cornerRadius
        viewFromXib.layer.borderColor = UIConfig.borderColor
        viewFromXib.layer.borderWidth = UIConfig.boarderWidth
        self.newsImageView.layer.cornerRadius = UIConfig.cornerRadius

        
    }

    func applyData(data: DMNewsCard, toastDelegate: ToastDelegate) {
        self.data = data
        self.toastDelegate = toastDelegate

        self.titleLabel.text = data.title 
        self.cateLabel.text = "| " + data.category
        self.ageLabel.text = data.computedAge


        Helper.asyncLoadImage(imageview: self.newsImageView, urlstr: data.thumbnailUrl)

        //init bookmark
        let marked = BookmarkManager.isMarked(artId: data.artId)
        self.articleBookmarked = marked
        self.changeBookmarkBtnState(to: marked)
        
        // add context menu
        self.addInteraction(UIContextMenuInteraction(delegate: self))
    }

}

//MARK: bookmark actions
extension TableNewsCardReusableContentView {
    private func toggleBookmark() {
        self.articleBookmarked = !self.articleBookmarked
        self.changeBookmarkBtnState(to: self.articleBookmarked)
        self.updateBookmarkDB(to: self.articleBookmarked)
    }
    private func changeBookmarkBtnState(to: Bool) {
        if to {
            //set to true, add bookmark
            self.bookmarkButton.setImage(BookmarkButtonUIConfig.imageMarked, for: .normal)
        } else {
            //set to false, remove bookmark
            self.bookmarkButton.setImage(BookmarkButtonUIConfig.imageUnmarked, for: .normal)
        }
    }

    private func updateBookmarkDB(to: Bool) {
        if to {
            //set to true, add bookmark
            BookmarkManager.addBookmark(item: data)
            self.toastDelegate?.toast("Article Bookmarked. Check out the Bookmarks tab to view")

        } else {
            //set to false, remove bookmark
            BookmarkManager.removeBookmark(artId: self.data?.artId)
            self.toastDelegate?.toast("Article removed from Bookmarks")
        }
    }

}
//MARK: Context Menu
extension TableNewsCardReusableContentView: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {


        let bookmarkIcon = self.articleBookmarked ? BookmarkButtonUIConfig.imageMarked : BookmarkButtonUIConfig.imageUnmarked

        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil) { _ in //don take suggest action
            let actionShareTwitter = UIAction(title: "Share with Twitter", image: #imageLiteral(resourceName: "twitter")) { (_) in
                if let data = self.data, !data.externalUrl.isEmpty {
                    Helper.openTwitterShareInSafari(link: data.externalUrl)
                } else {
                    Helper.warningToast(view: self, message: "Sorry, the share link of this item is invalid.", position: .center)
                }

            }
            let actionBookmark = UIAction(title: "Bookmark", image: bookmarkIcon) { _ in
                self.toggleBookmark()
            }
            return UIMenu(title: "Menu", children: [actionShareTwitter, actionBookmark])
        }
    }
}
