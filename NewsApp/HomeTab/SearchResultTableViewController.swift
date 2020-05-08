//
//  SearchResultTableViewController.swift
//  NewsApp
//
//  Created by Microos on 2020/5/2.
//  Copyright © 2020 Yiliang Xie. All rights reserved.
//

import UIKit
import SwiftSpinner
class SearchResultTableViewController: UITableViewController {


    //MARK: props
    private var searchKeyword = ""
    private var searchReusltsData = [DMNewsCard]()
    private var noResults: Bool {
        get {
            return searchReusltsData.isEmpty
        }
    }
    private var fetchedAlready = false


    override func viewDidLoad() {
    }

    func registerAsBookmarkNotificationReceiver(id: String) {
        BookmarkManager.registerAsNotificationReceiver(id: "SearchResultTableViewController#\(id)", receiver: self)
    }
    func applyData(keyword: String) {
        //early than did load
        self.searchKeyword = keyword
        self.fetchedAlready = false
    }


    func loadDone(ok: Bool, error: Any?) {
        print("Fetching Search Data Done")
        SwiftSpinner.hide()

        if !ok {
            let errMsg = error == nil ? "Empty Error Message" : "\(String(describing: error))"
            Helper.errorToast(view: self.view, message: "Faild to Load Search Results:\n\(errMsg)", duration: 5.0)
        } else {
            self.tableView.reloadData()
            if noResults {
                Helper.warningToast(view: self.view.superview, message: "No Search Results for \"\(self.searchKeyword)\"")
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if self.searchKeyword.isEmpty { return }
        if fetchedAlready { return }

        // fetch result if data is given
        SwiftSpinner.show("Loading Search Results..", animated: true)
        GuardianAPI.requestSearchData(q: self.searchKeyword) { (result) in
            switch result {
            case .success(let json):
                self.searchReusltsData = [DMNewsCard]()
                for (_, subjson) in json {
                    self.searchReusltsData.append(DMNewsCard(json: subjson))
                }
                self.loadDone(ok: true, error: nil)
            case .failure(let error):
                self.loadDone(ok: false, error: error)
            }
            self.fetchedAlready = true
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if searchKeyword.isEmpty { //show warning for empty keyword
            Helper.errorToast(view: self.view.superview, message: "No Input Keywords!")
        }
    }




}

//MARK: Segue Related
extension SearchResultTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if noResults {
            return
        }
        let data = self.searchReusltsData[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "NewsDetailViewController") as! NewsDetailViewController
        vc.applyData(data: data, id:"NewsDetail#FromSearchResults#\(data.title)")
        self.navigationController?.pushViewController(vc, animated: true)
    }



    @IBAction func performUnwind() {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: Table View Data Source
extension SearchResultTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchKeyword.isEmpty {
            return 0
        }
        if noResults {
            return 1
        }
        return searchReusltsData.count

    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if noResults {
            return tableView.dequeueReusableCell(withIdentifier: "IDSimpleLabelCell", for: indexPath)
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "IDNewsCardCellv2", for: indexPath)
        let cellContentView = cell.viewWithTag(1)! as! TableNewsCardReusableContentView
        cellContentView.applyData(data: self.searchReusltsData[indexPath.row], toastDelegate: self)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }

}


extension SearchResultTableViewController: ToastDelegate, BookmarkManagerDataChangeNotificationReceiver {
    func toast(_ message: String) {
        self.regularToast(message)
    }
    func bookmarkManagerDataChangezNotified() {
        self.tableView.reloadData()
    }
}
