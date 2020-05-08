//
//  BookmarksCollectionViewController.swift
//  NewsApp
//
//  Created by Microos on 2020/5/1.
//  Copyright © 2020 Yiliang Xie. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class BookmarksCollectionViewController: UICollectionViewController {

    var newsCardData = [DMNewsCard]()
    var isEmptyData: Bool {
        get {
            return newsCardData.isEmpty
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        setup()
    }

    func setup() {
        BookmarkManager.registerAsNotificationReceiver(id: "bookmarkCollectionVC", receiver: self)
        newsCardData = BookmarkManager.loadBookmarks()

    }


}

//MARK: Layout
extension BookmarksCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if isEmptyData {
            let size = self.collectionView.frame.size
            return CGSize(width: size.width, height: 30)
        }

        let viewWidth = self.collectionView.frame.size.width
        let cellWidth = (viewWidth - 3 * UIConfig.collectionViewItemVHSpacing) / 2
        let cellHeight = cellWidth * 1.4
        return CGSize(width: cellWidth, height: cellHeight)

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        if isEmptyData {
            let zero:CGFloat = 0
            let navBarHeight = self.navigationController?.navigationBar.frame.height ?? zero
            let tabBarHeight = self.tabBarController?.tabBar.frame.height ?? zero
            let collectionViewHeight = (self.collectionView?.frame.height)! - navBarHeight - tabBarHeight
            let itemsHeight: CGFloat = 30.0

            let topInset = collectionViewHeight / 2.0 - 2 * itemsHeight
            return UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        }

        let v = UIConfig.collectionViewItemVHSpacing
        return UIEdgeInsets(top: v, left: v, bottom: 0, right: v)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        //veritical spacing
        if isEmptyData { return 0 }
        return UIConfig.collectionViewItemVHSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        //horizontal space
        if isEmptyData { return 0 }
        return UIConfig.collectionViewItemVHSpacing
    }

}

// MARK: UICollectionViewDataSource
// MARK: BookmarkManagerDataChangeNotificationReceiver
extension BookmarksCollectionViewController: BookmarkManagerDataChangeNotificationReceiver {
    func bookmarkManagerDataChangezNotified() {
        self.newsCardData = BookmarkManager.loadBookmarks()
        self.collectionView.reloadData()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isEmptyData { return 1 }

        return self.newsCardData.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isEmptyData {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "IDEmptyDataCell", for: indexPath)

        }


        let cellData = newsCardData[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IDCell", for: indexPath)
        let cellContent = cell.viewWithTag(1) as! BookmarkCollectionCellContentView

        cellContent.applyData(data: cellData, toastDelegate: self)

        // Configure the cell
        cell.layer.cornerRadius = UIConfig.cornerRadius
//        cell.layer.borderColor = UIConfig.borderColor
//        cell.layer.borderWidth = UIConfig.boarderWidth


        return cell
    }

}


extension BookmarksCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isEmptyData {
            let detailVC = Helper.instantiateViewController("NewsDetailViewController") as! NewsDetailViewController
            detailVC.applyData(data: newsCardData[indexPath.item], id:"NewsDetail#FromBookmark#\(newsCardData[indexPath.item].title)")
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }

}



extension BookmarksCollectionViewController: ToastDelegate {
    func toast(_ message: String) {
        self.regularToast(message)
    }
}
