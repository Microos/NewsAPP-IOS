//
//  BookmarkCollectionCellContentView.swift
//  NewsApp
//
//  Created by Microos on 2020/5/1.
//  Copyright © 2020 Yiliang Xie. All rights reserved.
//

import UIKit


class BookmarkCollectionCellContentView: UIView {



    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var sectionLabel: UILabel!

    @IBOutlet weak var bookmarkButton: UIButton!


    var data: DMNewsCard?
    var toastDelegate: ToastDelegate?


    func removeBookmark() {
        self.toastDelegate?.toast("Article Removed from Bookmarks")
        BookmarkManager.removeBookmark(artId: self.data?.artId)
    }


    @IBAction func bookmarkButtonAction(_ sender: UIButton) {
        removeBookmark()
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
        let viewFromXib = Bundle.main.loadNibNamed("BookmarkCollectionCellContentView", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds // auto resize to fill in parent

        let bgcolor = #colorLiteral(red: 0.8904389739, green: 0.8905677199, blue: 0.911144197, alpha: 1)
        self.backgroundColor = bgcolor
//        let container = viewFromXib.viewWithTag(1)!
//        container.layer.cornerRadius = UIConfig.cornerRadius
//        container.layer.borderColor = UIConfig.borderColor
//        container.layer.borderWidth = UIConfig.boarderWidth
        let radius = UIConfig.cornerRadius
        self.layer.cornerRadius = radius
        self.layer.borderColor = UIConfig.borderColor
        self.layer.borderWidth = UIConfig.boarderWidth

        //setup image radius
        let path = UIBezierPath(roundedRect: newsImageView.bounds, byRoundingCorners: [ .topRight], cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        newsImageView.layer.mask = mask
        self.addSubview(viewFromXib)
    }


    func applyData(data: DMNewsCard, toastDelegate: ToastDelegate) {
        self.data = data
        self.toastDelegate = toastDelegate
        // add context menu
        self.addInteraction(UIContextMenuInteraction(delegate: self))

        Helper.asyncLoadImage(imageview: self.newsImageView, urlstr: data.thumbnailUrl)

        self.titleLabel.text = data.title
        self.pubDateLabel.text = data.pubDateForBookmark
        self.sectionLabel.text = "| " + data.category
    }
}

// context menu
extension BookmarkCollectionCellContentView: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let bookmarkIcon = BookmarkButtonUIConfig.imageMarked

        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil) { _ in //don take suggest action
            let actionShareTwitter = UIAction(title: "Share with Twitter", image: #imageLiteral(resourceName: "twitter")) { (_) in
                if let data = self.data {
                    Helper.openTwitterShareInSafari(link: data.externalUrl)
                } else {
                    Helper.warningToast(view: self.superview, message: "Sorry, the share link of this item is invalid.", position: .center)
                }

            }
            let actionBookmark = UIAction(title: "Bookmark", image: bookmarkIcon) { _ in
                self.removeBookmark()
            }
            return UIMenu(title: "Menu", children: [actionShareTwitter, actionBookmark])
        }
    }
}
