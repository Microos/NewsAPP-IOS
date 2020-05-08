//
//  XLPagerViewController.swift
//  NewsApp
//
//  Created by Microos on 2020/5/2.
//  Copyright © 2020 Yiliang Xie. All rights reserved.
//

import Foundation
import XLPagerTabStrip
class XLPagerViewController: ButtonBarPagerTabStripViewController {



    @IBOutlet weak var searchTableView: UITableView!
    private var resultDisplayTableVC: SearchResultTableViewController!
    private var searchResults = [String]()
    private var isSearchActivated: Bool {
        get {
            return !self.searchTableView.isHidden
        }
        set {
            self.containerView.isHidden = newValue
            self.buttonBarView.isHidden = newValue
            self.searchTableView.isHidden = !newValue
            self.searchTableView.reloadData()
        }
    }


    override func viewDidLoad() {
        setupPagerTabStripStyle()
        super.viewDidLoad()
        setup()
    }

    func getSearchResultVC() -> SearchResultTableViewController {
        if let vc = self.resultDisplayTableVC {
            return vc
        } else {
            self.resultDisplayTableVC = Helper.instantiateViewController("SearchResultTableViewController") as! SearchResultTableViewController
            self.resultDisplayTableVC?.registerAsBookmarkNotificationReceiver(id: "XLPager")
            return self.resultDisplayTableVC!
        }
    }

    func setupPagerTabStripStyle() {

        // change selected bar color
        let blue = #colorLiteral(red: 0.09240487963, green: 0.4876037836, blue: 0.9625456929, alpha: 1)
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white

        settings.style.selectedBarBackgroundColor = blue
        settings.style.buttonBarItemFont = .systemFont(ofSize: 16, weight: .medium)
        settings.style.selectedBarHeight = 3.0
        settings.style.buttonBarMinimumLineSpacing = 5
        settings.style.buttonBarItemTitleColor = .lightGray

        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0


        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .lightGray
            newCell?.label.textColor = blue
        }
    }

    func setup() {
        //setup search controller
        self.searchTableView.delegate = self
        self.searchTableView.dataSource = self
        self.searchTableView.isHidden = true
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Enter keyword.."
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        self.navigationItem.searchController = searchController

//        BookmarkManager.registerAsNotificationReceiver(id: "SearchResultTableViewController#XLPager", receiver: self.resultDisplayTableVC)


    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        var ret = [UIViewController]()
        for section in HeadlinesConfig.sectionNames {
            let vc = Helper.instantiateViewController("HeadlineSectionTableViewController") as! HeadlineSectionTableViewController
            vc.applyData(sectionName: section, toastDelegate: self)
            ret.append(vc)
        }
        return ret
    }
}

extension XLPagerViewController: ToastDelegate{
    func toast(_ message: String) {
        self.regularToast(message)
    }
}

extension XLPagerViewController: UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    //MARK: search bar
    func loadAutoSuggest(_ text: String?) {
        if text == nil {
            return
        }
        if text!.count < 3 {
            self.searchResults = [String]()
            self.searchTableView.reloadData()
            return
        }

        AutoSuggestAPI.requestSuggestion(text: text!, completion: {
            ok, resp in
            if(ok) {
                self.searchResults = resp
            } else {
                self.errorToast("Error on autosuggest request:\n\(self.searchResults[0])")
                self.searchResults = [String]()
            }
            self.searchTableView.reloadData()
        })
    }

    //change
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        loadAutoSuggest(searchBar.text)
    }
    //begin
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // could call from:
        //  - pure init
        //  - end then re begin (should already leave search)
        if let text = searchBar.text, text.count == 0 {
            self.searchResults = [String]()
        }

        self.isSearchActivated = true
    }
    //[!]search keydown
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, text.count != 0 {
//            let destVC = Helper.instantiateViewController("SearchResultsViewController") as! SearchResultTableViewController
            let destVC = self.getSearchResultVC()
            destVC.applyData(keyword: text)
            navigationController?.pushViewController(destVC, animated: true)
        }
    }

    //cancel
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //done
        self.searchResults = [String]()
        self.isSearchActivated = false
    }


    //MARK: table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchTableView.dequeueReusableCell(withIdentifier: "IDSimpleLabelCell")!
        let label = cell.viewWithTag(1)! as! UILabel
        label.text = self.searchResults[indexPath.row]
        return cell
    }
    //[!]tap on cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let destVC = Helper.instantiateViewController("SearchResultsViewController") as! SearchResultTableViewController
        let destVC = self.getSearchResultVC()
        destVC.applyData(keyword: searchResults[indexPath.row])
        navigationController?.pushViewController(destVC, animated: true)
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }



}
