//
//  HomeTabTableViewController.swift
//  NewsApp
//
//  Created by Microos on 2020/4/28.
//  Copyright © 2020 Yiliang Xie. All rights reserved.
//

import UIKit
import os.log
import CoreLocation
import SwiftSpinner
import Toast_Swift
class HomeTableViewController: UITableViewController {

    //MARK: props
    private var newsCardData = [DMNewsCard]()
    private var weatherData = [String: String]()
    private var searchResults = [String]()
    private var isSearchActivated = false

    private var taskGroup: DispatchGroup! // = DispatchGroup()
    private var taskCount = 0
    private var weatherToastCount = 1
    private var locationMananger = CLLocationManager()
    private var resultDisplayTableVC: SearchResultTableViewController!


    override func viewDidLoad() {
        super.viewDidLoad()

        setup()

    }
    override func viewDidAppear(_ animated: Bool) {
        if newsCardData.isEmpty {
            if UIConfig.showSpinner {
                SwiftSpinner.show("Loading Home Page..", animated: true)
            }
            self.loadNewsAndWeatherData()
        }
    }



    func setup() {
        //register as notifable
        BookmarkManager.registerAsNotificationReceiver(id: "HomeTableViewController", receiver: self)


        //setup search controller
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Enter keyword.."
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        self.navigationItem.searchController = searchController

        //setup toast
        ToastManager.shared.isTapToDismissEnabled = true
        ToastManager.shared.isQueueEnabled = true
        ToastManager.shared.duration = 2.0

        //setup location manager
        CLHelper.configCLManager(manager: self.locationMananger, delegate: self)
    }






    //MARK: IB actions
    @IBAction func pullRefresh(_ sender: UIRefreshControl) {

        if UIConfig.showSpinner {
            SwiftSpinner.show("Loading Home Page..", animated: true)
        }

        self.loadNewsAndWeatherData()
        sender.endRefreshing()
    }

    func resetData() {
        self.newsCardData.removeAll()
        self.weatherToastCount = 1
        self.weatherData = [String: String]()
        self.tableView.reloadData()
    }

    // MARK: Loading Data
    func loadNewsAndWeatherData() {
        resetData()
        initTaskGroup()
        //load news
        enterTask()
        GuardianAPI.requestHomeData(completion: { result in
            self.leaveTask()
            switch result {
            case .success(let arr):
                self.newsCardData = arr
            case .failure(let err):
                self.errorToast("Fetch News Error:\n\(err)")
            }
        })

        //load weather
        self.locationMananger.startUpdatingLocation()
//        self.locationMananger.requestLocation()
        print("GPS On")
        taskGroup.notify(queue: .main, execute: {
            print("Weather/News Data All Resulted")
            self.tableView.reloadData()
            if UIConfig.showSpinner {
                SwiftSpinner.hide()
            }
        })
    }
}

//MARK: Segue realted
extension HomeTableViewController {
    func getSearchResultVC() -> SearchResultTableViewController {
        if let vc = self.resultDisplayTableVC {
            return vc
        } else {
            self.resultDisplayTableVC = Helper.instantiateViewController("SearchResultTableViewController") as! SearchResultTableViewController
            self.resultDisplayTableVC?.registerAsBookmarkNotificationReceiver(id: "HomeTab")
            return self.resultDisplayTableVC!
        }
    }
    //[!] cell tabbed
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearchActivated {
//            let destVC = Helper.instantiateViewController("SearchResultsViewController") as! SearchResultTableViewController
            let destVC = self.getSearchResultVC()
            destVC.applyData(keyword: self.searchResults[indexPath.row])
            self.navigationController?.pushViewController(destVC, animated: true)
        } else {
            let detailVC = Helper.instantiateViewController("NewsDetailViewController") as! NewsDetailViewController
            detailVC.applyData(data: newsCardData[indexPath.row - 1], id:"NewsDetail#FromHomeTab#\(newsCardData[indexPath.row - 1].title)")
            self.navigationController?.pushViewController(detailVC, animated: true)
        }


    }
}


//MARK: UISearchBarDelegate
extension HomeTableViewController: UISearchBarDelegate {

    func setSearchActiveState(_ to: Bool) {
        self.isSearchActivated = to

        self.tableView.separatorStyle = to ? .singleLine : .none
        self.tableView.rowHeight = to ? 44 : 130
        self.tableView.reloadData()
    }

    func loadAutoSuggest(_ text: String?) {
        if text == nil {
            return
        }
        if text!.count < 3 {
            self.searchResults = [String]()
            self.tableView.reloadData()
            return
        }

        AutoSuggestAPI.requestSuggestion(text: text!, completion: {
            ok, resp in
            if(ok) {
                self.searchResults = resp
            } else {

                self.warningToast("Error on autosuggest request:\n\(self.searchResults[0])")
                self.searchResults = [String]()
            }
            self.tableView.reloadData()
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

        setSearchActiveState(true)
    }

    //search keydown[!]
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, text.count != 0 {
//            let destVC = Helper.instantiateViewController("SearchResultsViewController") as! SearchResultTableViewController
            let destVC = self.getSearchResultVC()
            destVC.applyData(keyword: text)
            self.navigationController?.pushViewController(destVC, animated: true)
        }
    }

    //cancel
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //done
        self.searchResults = [String]()
        setSearchActiveState(false)
    }


}

//MARK: Table View Data Source
extension HomeTableViewController: BookmarkManagerDataChangeNotificationReceiver {
    func bookmarkManagerDataChangezNotified() {
        self.tableView.reloadData()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearchActivated {
            return self.searchResults.count
        } else {
//            let weatherDataCount = self.weatherData.isEmpty ? 0 : 1
            return newsCardData.count + 1
        }

    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isSearchActivated {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IDSimpleLabelCell", for: indexPath)
            let label = cell.viewWithTag(1) as! UILabel
            label.text = searchResults[indexPath.row]
            return cell
        }
        //else
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IDWeatherCell", for: indexPath) as! WeatherTableViewCell
            cell.applyData(data: self.weatherData)
            return cell

        default:
            let data = newsCardData[indexPath.row - 1] //offset of News data idx
            let cell = tableView.dequeueReusableCell(withIdentifier: "IDNewsCardCellv2", for: indexPath)
            let newsCardView = cell.viewWithTag(1) as! TableNewsCardReusableContentView //TableNewsCardContentView

            newsCardView.applyData(data: data, toastDelegate: self)
//            newsCardView.addInteraction(UIContextMenuInteraction(delegate: newsCardView))
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isSearchActivated {
            return 44 // for search result
        } else {
            return 130 //for news card data
        }
    }
}

//MARK: CLLocationManagerDelegate
extension HomeTableViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //can not parse GPS coords
        guard let loc: CLLocationCoordinate2D = manager.location?.coordinate else {
            os_log("Failed to update location", log: OSLog.default, type: .error)
            return
        }
        print("Receive Updated Loction = \(loc.longitude),\(loc.latitude)")

        if self.weatherData["temp"] != nil {
            print("GPS off: temp is known")
            self.locationMananger.stopUpdatingLocation()
            return
        }

        CLHelper.locationToCityName(lat: loc.latitude, lon: loc.longitude, complete: {
            city, state, country in
            if let city = city, let country = country {
                if self.weatherData["temp"] != nil {
                    print("GPS off: temp is known")
                    self.locationMananger.stopUpdatingLocation()
                    return
                }
                self.weatherData["city"] = city
                self.weatherData["state"] = CLHelper.stateCodeToName(code: state ?? "N/A")
                self.tableView.reloadData()
                print("GPS name: [\(city)], [\(state ?? "NoState")], [\(country)]")
                WeatherAPI.requestWeather(city: city, state: state, country: country, lon: loc.longitude, lat: loc.latitude, completion: {
                    dict in
                    if let dict = dict {
                        //data succeed
//                        if self.weatherData["temp"] == nil {
                        //weather dict not yet set
                        print("Weather Data Loaded: using location lat=\(loc.latitude); lon=\(loc.longitude)")
                        self.weatherData = dict
                        self.tableView.reloadData()
//                        }
                        print("GPS off: fetch data succeed")
                        self.locationMananger.stopUpdatingLocation()
                    } else {
                        print("GPS off: fetch data failed")
                        self.locationMananger.stopUpdatingLocation()
//                        self.errorToast("WeatherAPI Failiure\nFailed at fetchWeather()")
                        self.weatherErrorToast("WeatherAPI Failiure\nFailed at fetchWeather()")
                    }

                })
            }
        })
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        self.taskGroup.leave()
        self.errorToast("Location Fetch Failed:\n\(error)")
    }

    func weatherErrorToast(_ message: String) {
        if self.weatherToastCount > 0 {
            self.errorToast(message)
        }
    }
    func initTaskGroup() {
        self.taskGroup = DispatchGroup()
        self.taskCount = 0

    }
    func enterTask() {
        self.taskGroup.enter()
        self.taskCount += 1
    }
    func leaveTask() {
        if (self.taskCount > 0) {
            self.taskGroup.leave()
            self.taskCount -= 1
        } else {
            print("Task Group Counter is \(self.taskCount), ignored")
        }
    }
}

//MARK: ToastDelegate
extension HomeTableViewController: ToastDelegate {
    func toast(_ message: String) {
        self.regularToast(message)
    }



}



