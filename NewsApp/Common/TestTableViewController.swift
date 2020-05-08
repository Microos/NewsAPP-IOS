//
//  TestTableViewController.swift
//  NewsApp
//
//  Created by Microos on 2020/4/30.
//  Copyright © 2020 Yiliang Xie. All rights reserved.
//

import UIKit

import SwiftSpinner

class TestTableViewController: UITableViewController {
    var data = BookmarkManager.loadBookmarks()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //SwiftSpinner.show("adasd", animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
       
    }
    override func viewDidAppear(_ animated: Bool) {
        SwiftSpinner.show("qqq", animated: true)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell0", for: indexPath)
        let newsCardView = cell.viewWithTag(2) as! TableNewsCardReusableContentView //TableNewsCardContentView

        newsCardView.applyData(data: data[indexPath.row], toastDelegate: self)
        return cell
    }


}

extension TestTableViewController: ToastDelegate{
    func toast(_ message: String) {
        self.regularToast(message)
    }
}
