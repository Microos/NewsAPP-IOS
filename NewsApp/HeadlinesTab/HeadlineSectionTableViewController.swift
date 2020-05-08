//
//  HeadlineSectionTableViewController.swift
//  NewsApp
//
//  Created by Microos on 2020/5/2.
//  Copyright © 2020 Yiliang Xie. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftSpinner

class HeadlineSectionTableViewController: UITableViewController {
    private var sectionName: String?
    private var newsCardData = [DMNewsCard]()
    private var dataFetchedAlready = false
    private var toastDelegate: ToastDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        if !dataFetchedAlready {
            self.fetchData()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
    }
    func applyData(sectionName: String, toastDelegate: ToastDelegate) {
        self.sectionName = sectionName
        self.toastDelegate = toastDelegate
        BookmarkManager.registerAsNotificationReceiver(id: "HeadlineSectionTableViewController#\(sectionName)", receiver: self)
    }

    func fetchData() {
        if let section = self.sectionName {
            SwiftSpinner.show("Loading \(section.uppercased()) Headlines")
            GuardianAPI.requestHeadlinesData(forSection: section) { (result) in
                switch result {
                case .success(let arr):
                    self.newsCardData = arr
                    self.tableView.reloadData()
                case .failure(let err):
                    self.errorToast("Error Fetch Data: \(err)")
                }
                self.dataFetchedAlready = true
                SwiftSpinner.hide()
                self.refreshControl?.endRefreshing()
            }
        } else {
            self.errorToast("Unexpected Error: Nil sectionName at the time loadData(). Please check instantiation calls.")
        }
    }


    @IBAction func pullRefresh(_ sender: UIRefreshControl) {
        newsCardData = [DMNewsCard]()
        dataFetchedAlready = false
        tableView.reloadData()
        fetchData()
        
    }


}
// MARK: Segue related
extension HeadlineSectionTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.newsCardData[indexPath.row]
        let destVC = Helper.instantiateViewController("NewsDetailViewController") as! NewsDetailViewController
        destVC.applyData(data: data, id:"NewsDetail#FromHeadlines#\(data.title)")
        self.navigationController?.pushViewController(destVC, animated: true)
    }
}
// MARK: Table view data source
extension HeadlineSectionTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsCardData.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "IDNewsCardCellv2")!
        let cellContent = cell.viewWithTag(1) as! TableNewsCardReusableContentView
        cellContent.applyData(data: self.newsCardData[indexPath.row], toastDelegate: self.toastDelegate)
        return cell
    }
}


extension HeadlineSectionTableViewController: IndicatorInfoProvider, BookmarkManagerDataChangeNotificationReceiver {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: self.sectionName!.uppercased())
    }
   

    func bookmarkManagerDataChangezNotified() {
        self.tableView.reloadData()
    }
}
